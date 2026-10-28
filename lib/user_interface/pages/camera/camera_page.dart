import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_frame_analyzer.dart';
import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/rules/field/sky.dart';
import 'package:druid_app/business_logic/services/camera/photo_resizer.dart';
import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/// Centro della Zona, per i tratti del cielo finché il GPS non risponde (nel prototipo la Zona è Bologna).
const _zoneCenter = (latitude: 44.4937, longitude: 11.3430);

/// Fotocamera dell'app (step 1b del Campo, capitolo 07): mirino con i tratti del cielo e la precisione del GPS,
/// streaming dei fotogrammi analizzato mentre si inquadra (senza registrare niente), scatto a piena risoluzione
/// ridotto a 1600 px. Si chiude con la foto ([TakenPhoto]) o senza ([TakenPhoto.cancelled]).
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  /// Al massimo un fotogramma analizzato ogni 100 ms (10 al secondo): la verifica non ha bisogno di più.
  static const _analysisInterval = Duration(milliseconds: 100);

  final IFrameAnalyzer _analyzer = Get.find();
  final IClock _clock = Get.find();
  final bool _debug = Get.find<AppConfig>().showDebugTools;

  CameraController? _camera;
  String? _error;
  LocationRecording? _location;
  StreamSubscription<LocationFix>? _fixes;
  LocationFix? _bestFix;
  bool _locationOff = false;

  FrameVerdict _verdict = FrameVerdict.waiting;
  final _streamWatch = Stopwatch();
  final _sinceAnalysis = Stopwatch();
  int _received = 0, _analyzed = 0, _analysisMicros = 0;
  bool _shooting = false;
  Timer? _debugTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
    _startLocation();
    if (_debug) _debugTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debugTimer?.cancel();
    _closeCamera();
    _fixes?.cancel();
    _location?.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // La fotocamera si libera quando l'app va dietro e si riapre al ritorno.
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _closeCamera();
    } else if (state == AppLifecycleState.resumed && _camera == null && !_shooting) {
      _openCamera();
    }
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.where((c) => c.lensDirection == CameraLensDirection.back).firstOrNull ?? cameras.first;
      final camera = CameraController(
        back,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      _camera = camera;
      await camera.initialize();
      if (!mounted || _camera != camera) return;
      _analyzer.reset();
      _streamWatch
        ..reset()
        ..start();
      _received = _analyzed = _analysisMicros = 0;
      await camera.startImageStream(_onFrame);
      setState(() => _error = null);
    } on CameraException catch (e) {
      _camera = null;
      if (mounted) setState(() => _error = e.code);
    }
  }

  Future<void> _closeCamera() async {
    final camera = _camera;
    _camera = null;
    await camera?.dispose();
  }

  Future<void> _startLocation() async {
    final result = await Get.find<ILocationSampler>().start();
    if (!mounted) {
      result.fold((_) {}, (recording) => unawaited(recording.stop()));
      return;
    }
    result.fold((_) => setState(() => _locationOff = true), (recording) {
      _location = recording;
      _fixes = recording.updates.listen((fix) {
        if (_bestFix == null || fix.accuracy <= _bestFix!.accuracy) setState(() => _bestFix = fix);
      });
    });
  }

  void _onFrame(CameraImage image) {
    _received++;
    if (_sinceAnalysis.isRunning && _sinceAnalysis.elapsed < _analysisInterval) return;
    _sinceAnalysis
      ..reset()
      ..start();
    final watch = Stopwatch()..start();
    final plane = image.planes.first;
    final verdict = _analyzer.analyze(
      CameraFrame(width: image.width, height: image.height, bytesPerRow: plane.bytesPerRow, luma: plane.bytes),
    );
    _analysisMicros += watch.elapsedMicroseconds;
    _analyzed++;
    if (verdict.ready != _verdict.ready) {
      setState(() => _verdict = verdict);
    } else {
      _verdict = verdict;
    }
  }

  CameraDiagnostics _diagnostics({required int captureMs, required int resizeMs}) {
    final seconds = _streamWatch.elapsedMilliseconds / 1000;
    return CameraDiagnostics(
      receivedPerSecond: seconds == 0 ? 0 : _received / seconds,
      analyzedPerSecond: seconds == 0 ? 0 : _analyzed / seconds,
      analysisMs: _analyzed == 0 ? 0 : _analysisMicros / _analyzed / 1000,
      captureMs: captureMs,
      resizeMs: resizeMs,
    );
  }

  Future<void> _shoot() async {
    final camera = _camera;
    if (camera == null || _shooting || !_verdict.ready) return;
    setState(() => _shooting = true);
    try {
      _streamWatch.stop();
      final watch = Stopwatch()..start();
      await camera.stopImageStream();
      final file = await camera.takePicture();
      final captureMs = watch.elapsedMilliseconds;
      final bytes = await file.readAsBytes();
      watch.reset();
      final resized = await Isolate.run(() => resizeJpeg(bytes));
      final resizeMs = watch.elapsedMilliseconds;
      final directory = Directory('${(await getApplicationDocumentsDirectory()).path}/photos');
      await directory.create(recursive: true);
      final path = '${directory.path}/${_clock.now().millisecondsSinceEpoch}.jpg';
      await File(path).writeAsBytes(resized, flush: true);
      // L'originale a piena risoluzione non serve più (la foto resta solo ridotta).
      try {
        await File(file.path).delete();
      } on FileSystemException {
        // Già cancellato dalla fotocamera: niente da fare.
      }
      if (mounted) {
        Navigator.of(context).pop(
          TakenPhoto(
            path,
            diagnostics: _diagnostics(captureMs: captureMs, resizeMs: resizeMs),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _shooting = false;
          _error = '$e';
        });
      }
    }
  }

  // Come ogni fotocamera il mirino è scuro, con qualsiasi tema: si usa il tema scuro della livrea.
  @override
  Widget build(BuildContext context) => Theme(
    data: Get.find<ThemeController>().darkTheme,
    child: Builder(builder: _viewfinder),
  );

  Widget _viewfinder(BuildContext context) {
    final camera = _camera;
    final position = _bestFix;
    final live = _diagnostics(captureMs: 0, resizeMs: 0);
    final sky = skyTraits(
      _clock.now(),
      position?.latitude ?? _zoneCenter.latitude,
      position?.longitude ?? _zoneCenter.longitude,
    );
    return Scaffold(
      backgroundColor: context.colors.scrim,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (camera != null && camera.value.isInitialized)
            // Anteprima a tutto schermo, ritagliata ai lati (previewSize è in orizzontale).
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: camera.value.previewSize!.height,
                height: camera.value.previewSize!.width,
                child: CameraPreview(camera),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(Gaps.xl),
                child: Text(
                  _error == 'CameraAccessDenied' || _error == 'CameraAccessDeniedWithoutPrompt'
                      ? context.l10n.cameraDenied
                      : context.l10n.cameraError(_error!),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.colors.onSurface),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Gaps.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Readout(
                    key: const ValueKey('camera-readout'),
                    sky: sky,
                    accuracy: position?.accuracy,
                    locationOff: _locationOff,
                  ),
                  const Spacer(),
                  if (_debug)
                    _Plate(
                      child: Text(
                        context.l10n.cameraDebug(
                          live.receivedPerSecond.toStringAsFixed(0),
                          live.analyzedPerSecond.toStringAsFixed(1),
                          live.analysisMs.toStringAsFixed(1),
                          _verdict.sharpness.toStringAsFixed(0),
                          _verdict.motion.toStringAsFixed(1),
                        ),
                        style: context.texts.bodySmall?.copyWith(color: context.colors.onSurface),
                      ),
                    ),
                  const SizedBox(height: Gaps.l),
                  Row(
                    children: [
                      IconButton(
                        key: const ValueKey('camera-close'),
                        tooltip: context.l10n.cameraClose,
                        color: context.colors.onSurface,
                        onPressed: () => Navigator.of(context).pop(TakenPhoto.cancelled),
                        icon: const Icon(Icons.close_rounded, size: 32),
                      ),
                      const Spacer(),
                      _Shutter(
                        enabled: camera != null && _verdict.ready && !_shooting,
                        busy: _shooting,
                        onPressed: _shoot,
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il display del mirino, come ISO e diaframma su una fotocamera: i tratti del cielo adesso e il GPS.
class _Readout extends StatelessWidget {
  final List<Trait> sky;
  final double? accuracy;
  final bool locationOff;

  const _Readout({super.key, required this.sky, required this.accuracy, required this.locationOff});

  @override
  Widget build(BuildContext context) {
    final style = context.texts.labelLarge?.copyWith(color: context.colors.onSurface);
    return Wrap(
      spacing: Gaps.s,
      runSpacing: Gaps.s,
      children: [
        for (final trait in sky) _Plate(child: Text(context.game.trait(trait), style: style)),
        _Plate(
          child: Text(
            locationOff
                ? context.l10n.cameraGpsOff
                : accuracy == null
                ? context.l10n.cameraGpsSearching
                : context.l10n.cameraGps(accuracy!.round()),
            style: style,
          ),
        ),
      ],
    );
  }
}

/// Targhetta scura e trasparente sopra l'immagine.
class _Plate extends StatelessWidget {
  final Widget child;

  const _Plate({required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(Gaps.s),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gaps.m, vertical: Gaps.xs),
      child: child,
    ),
  );
}

class _Shutter extends StatelessWidget {
  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  const _Shutter({required this.enabled, required this.busy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final ring = context.colors.onSurface.withValues(alpha: enabled ? 1 : 0.4);
    return Semantics(
      button: true,
      label: context.l10n.cameraShutter,
      child: GestureDetector(
        key: const ValueKey('camera-shutter'),
        onTap: enabled ? onPressed : null,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 4),
          ),
          padding: const EdgeInsets.all(6),
          child: busy
              ? CircularProgressIndicator(color: ring)
              : DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: ring),
                ),
        ),
      ),
    );
  }
}
