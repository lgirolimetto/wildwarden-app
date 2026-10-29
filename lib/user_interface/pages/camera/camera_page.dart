import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_frame_analyzer.dart';
import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_weather_service.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/location_fix.dart';
import 'package:druid_app/business_logic/models/plant_identification.dart';
import 'package:druid_app/business_logic/models/weather_now.dart';
import 'package:druid_app/business_logic/rules/field/sky.dart';
import 'package:druid_app/business_logic/rules/field/vis_gathering.dart';
import 'package:druid_app/business_logic/rules/field/weather_traits.dart';
import 'package:druid_app/business_logic/services/camera/photo_resizer.dart';
import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/// Centro della Zona, per i tratti del cielo finché il GPS non risponde (nel prototipo la Zona è Bologna).
const _zoneCenter = (latitude: 44.4937, longitude: 11.3430);

/// Gradini dello zoom sotto il mirino (1×, 2×, 5×) fino al massimo della fotocamera: per inquadrare bene una pianta
/// anche da qualche metro, per sicurezza o per rispetto (senza calpestare o avvicinarsi troppo).
List<double> zoomStops(double maxZoom) => [
  for (final stop in const [1.0, 2.0, 5.0])
    if (stop <= maxZoom) stop,
];

/// "2×", "2.4×": lo zoom come lo scrivono le fotocamere.
String zoomLabel(double zoom) {
  final rounded = (zoom * 10).round() / 10;
  return '${rounded == rounded.roundToDouble() ? rounded.toInt() : rounded}×';
}

/// Fotocamera dell'app (step 1b del Campo, capitolo 07): mirino con i tratti del cielo e la precisione del GPS,
/// streaming dei fotogrammi analizzato mentre si inquadra (senza registrare niente), scatto a piena risoluzione
/// ridotto a 1600 px. Si chiude con la foto ([TakenPhoto]) o senza ([TakenPhoto.cancelled]).
class CameraPage extends StatefulWidget {
  /// Uno scatto solo, la pianta intera: Attingere alla tua Stazione (blocco 3), senza foglia e fiore per Pl@ntNet.
  final bool single;

  const CameraPage({super.key, this.single = false});

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

  // Il meteo si chiede una volta, appena c'è una posizione (o dopo qualche secondo, al centro della Zona).
  WeatherNow? _weather;
  bool _weatherAsked = false;
  Timer? _weatherFallback;

  FrameVerdict _verdict = FrameVerdict.none;
  final _vis = VisGathering();
  final _streamWatch = Stopwatch();
  final _sinceAnalysis = Stopwatch();
  int _received = 0, _analyzed = 0, _analysisMicros = 0;
  String _frameSize = '';
  bool _shooting = false;
  Timer? _debugTimer;

  // Zoom (pizzico o gradini) e flash: si riapplicano quando la fotocamera si riapre.
  double _minZoom = 1, _maxZoom = 1, _zoom = 1, _pinchStartZoom = 1;
  FlashMode _flash = FlashMode.off;
  bool _hasFlash = true;

  // Le foto della pianta: intera, foglia, fiore (se c'è). Vanno a Pl@ntNet insieme (capitolo 02).
  final _shots = <PlantPhoto>[];
  int _captureMs = 0, _resizeMs = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Tutto lo schermo all'immagine: le barre di Android tornano con un trascinamento dal bordo.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _openCamera();
    _startLocation();
    _weatherFallback = Timer(const Duration(seconds: 5), () => _loadWeather(_bestFix));
    if (_debug) _debugTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _debugTimer?.cancel();
    _weatherFallback?.cancel();
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
      _minZoom = await camera.getMinZoomLevel();
      _maxZoom = await camera.getMaxZoomLevel();
      _zoom = _zoom.clamp(_minZoom, _maxZoom);
      await camera.setZoomLevel(_zoom);
      try {
        await camera.setFlashMode(_flash);
      } on CameraException {
        _hasFlash = false;
      }
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

  Future<void> _setZoom(double zoom) async {
    final camera = _camera;
    if (camera == null) return;
    setState(() => _zoom = zoom.clamp(_minZoom, _maxZoom));
    try {
      await camera.setZoomLevel(_zoom);
    } on CameraException {
      // La fotocamera si sta chiudendo: lo zoom si riapplica alla riapertura.
    }
  }

  Future<void> _nextFlash() async {
    final camera = _camera;
    if (camera == null) return;
    final next = switch (_flash) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };
    try {
      await camera.setFlashMode(next);
      setState(() => _flash = next);
    } on CameraException {
      setState(() => _hasFlash = false);
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
        _loadWeather(fix);
      });
    });
  }

  Future<void> _loadWeather(LocationFix? fix) async {
    if (_weatherAsked) return;
    _weatherAsked = true;
    _weatherFallback?.cancel();
    final result = await Get.find<IWeatherService>().now(
      fix?.latitude ?? _zoneCenter.latitude,
      fix?.longitude ?? _zoneCenter.longitude,
    );
    // Senza rete il mirino mostra solo il cielo: il meteo non è indispensabile per scattare.
    if (mounted) result.fold((_) {}, (weather) => setState(() => _weather = weather));
  }

  void _onFrame(CameraImage image) {
    _received++;
    _frameSize = '${image.width}×${image.height}';
    if (_sinceAnalysis.isRunning && _sinceAnalysis.elapsed < _analysisInterval) return;
    final step = _sinceAnalysis.isRunning ? _sinceAnalysis.elapsed : Duration.zero;
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
    _verdict = verdict;
    if (_shooting) return;
    if (_vis.update(step: step, evidence: verdict.evidence, zoom: _zoom)) unawaited(HapticFeedback.mediumImpact());
    setState(() {});
  }

  CameraDiagnostics _diagnostics({required int captureMs, required int resizeMs}) {
    final seconds = _streamWatch.elapsedMilliseconds / 1000;
    return CameraDiagnostics(
      receivedPerSecond: seconds == 0 ? 0 : _received / seconds,
      analyzedPerSecond: seconds == 0 ? 0 : _analyzed / seconds,
      analysisMs: _analyzed == 0 ? 0 : _analysisMicros / _analyzed / 1000,
      captureMs: captureMs,
      resizeMs: resizeMs,
      zoom: _zoom,
      flash: _hasFlash ? _flash.name : 'none',
    );
  }

  Future<void> _shoot() async {
    final camera = _camera;
    if (camera == null || _shooting || !_vis.canShoot) return;
    setState(() => _shooting = true);
    try {
      _streamWatch.stop();
      final watch = Stopwatch()..start();
      await camera.stopImageStream();
      final file = await camera.takePicture();
      final captureMs = watch.elapsedMilliseconds;
      final bytes = await file.readAsBytes();
      watch.reset();
      final resized = await resizeJpegInBackground(bytes);
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
      if (_shots.isEmpty) {
        _captureMs = captureMs;
        _resizeMs = resizeMs;
      }
      _shots.add(PlantPhoto(path, PlantOrgan.values[_shots.length]));
      _vis.shotTaken();
      if (!mounted) return;
      unawaited(HapticFeedback.lightImpact());
      if (widget.single || _shots.length == PlantOrgan.values.length) return _finish();
      // Si continua a raccogliere la Vis per il prossimo scatto: lo streaming riparte.
      _sinceAnalysis.reset();
      _streamWatch.start();
      await camera.startImageStream(_onFrame);
      if (mounted) setState(() => _shooting = false);
    } catch (e) {
      // Qualsiasi errore (fotocamera, file, riduzione) sblocca lo scatto e si mostra: niente pulsante bloccato.
      if (mounted) {
        setState(() {
          _shooting = false;
          _error = '$e';
        });
      }
    }
  }

  /// Fine: le foto scattate (il fiore si può saltare) con i tratti del momento.
  void _finish() => Navigator.of(context).pop(
    TakenPhoto(
      photos: List.unmodifiable(_shots),
      traits: _traitsNow(),
      position: _bestFix,
      diagnostics: _diagnostics(captureMs: _captureMs, resizeMs: _resizeMs),
      verified: _vis.moved,
      visGathered: _vis.progress,
    ),
  );

  /// Chiudere senza finire butta le foto già scattate.
  void _cancel() {
    for (final shot in _shots) {
      File(shot.path).delete().ignore();
    }
    Navigator.of(context).pop(TakenPhoto.cancelled);
  }

  /// I tratti di adesso, qui: il cielo (luce e luna) e il meteo.
  List<Trait> _traitsNow() {
    final latitude = _bestFix?.latitude ?? _zoneCenter.latitude;
    final longitude = _bestFix?.longitude ?? _zoneCenter.longitude;
    final weather = _weather;
    return [
      ...skyTraits(_clock.now(), latitude, longitude),
      if (weather != null) ...weatherTraits(weather, latitude, longitude),
    ];
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
    final sky = _traitsNow();
    return Scaffold(
      backgroundColor: context.colors.scrim,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (camera != null && camera.value.isInitialized)
            // Anteprima a tutto schermo, ritagliata ai lati (previewSize è in orizzontale).
            // Con due dita si avvicina e si allontana (zoom).
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (_) => _pinchStartZoom = _zoom,
              onScaleUpdate: (details) {
                if (details.pointerCount > 1) _setZoom(_pinchStartZoom * details.scale);
              },
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: camera.value.previewSize!.height,
                  height: camera.value.previewSize!.width,
                  child: CameraPreview(camera),
                ),
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
                          _frameSize,
                          live.receivedPerSecond.toStringAsFixed(0),
                          live.analyzedPerSecond.toStringAsFixed(1),
                          live.analysisMs.toStringAsFixed(1),
                          _verdict.sharpness.toStringAsFixed(0),
                          '${_verdict.motion.toStringAsFixed(1)} · Vis ${(_vis.progress * 100).round()} %',
                        ),

                        style: context.texts.bodySmall?.copyWith(color: context.colors.onSurface),
                      ),
                    ),
                  const SizedBox(height: Gaps.l),
                  if (camera != null)
                    Center(
                      child: _Hint(switch (_shots.length) {
                        _ when widget.single => context.l10n.cameraDrawHint,
                        0 => context.l10n.cameraGatherHint,
                        1 => context.l10n.cameraLeafHint,
                        _ => context.l10n.cameraFlowerHint,
                      }),
                    ),
                  if (camera != null && _vis.zoomed) Center(child: _Hint(context.l10n.cameraZoomSlower)),
                  if (camera != null && _shots.length == 2 && !_shooting)
                    Center(
                      child: TextButton(
                        key: const ValueKey('camera-no-flower'),
                        style: TextButton.styleFrom(foregroundColor: context.colors.onSurface),
                        onPressed: _finish,
                        child: Text(context.l10n.cameraNoFlower),
                      ),
                    ),
                  const SizedBox(height: Gaps.m),
                  if (camera != null && !widget.single) Center(child: _OrganSteps(done: _shots.length)),
                  const SizedBox(height: Gaps.m),
                  if (camera != null && zoomStops(_maxZoom).length > 1)
                    Center(
                      child: _ZoomStops(stops: zoomStops(_maxZoom), zoom: _zoom, onSelected: _setZoom),
                    ),
                  const SizedBox(height: Gaps.m),
                  Row(
                    children: [
                      IconButton(
                        key: const ValueKey('camera-close'),
                        onPressed: _cancel,
                        icon: _Glyph(icon: Icons.close_rounded, label: context.l10n.cameraClose, size: 32),
                      ),
                      const Spacer(),
                      _Shutter(
                        progress: _vis.progress,
                        full: _vis.canShoot,
                        enabled: camera != null && _vis.canShoot && !_shooting,
                        busy: _shooting,
                        onPressed: _shoot,
                        onLocked: () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text(context.l10n.cameraShutterLocked))),
                      ),
                      const Spacer(),
                      if (_hasFlash)
                        IconButton(
                          key: const ValueKey('camera-flash'),
                          onPressed: camera == null ? null : _nextFlash,
                          icon: switch (_flash) {
                            FlashMode.auto => _Glyph(
                              icon: Icons.flash_auto_rounded,
                              label: context.l10n.cameraFlashAuto,
                              size: 30,
                            ),
                            FlashMode.always => _Glyph(
                              icon: Icons.flash_on_rounded,
                              label: context.l10n.cameraFlashOn,
                              size: 30,
                            ),
                            _ => _Glyph(icon: Icons.flash_off_rounded, label: context.l10n.cameraFlashOff, size: 30),
                          },
                        )
                      else
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

/// Il display del mirino, come ISO e diaframma su una fotocamera: solo icone sopra l'immagine (i tratti del cielo
/// adesso e il GPS), come in realtà aumentata. Il testo resta per l'accessibilità.
class _Readout extends StatelessWidget {
  static const _size = 30.0;

  final List<Trait> sky;
  final double? accuracy;
  final bool locationOff;

  const _Readout({super.key, required this.sky, required this.accuracy, required this.locationOff});

  @override
  Widget build(BuildContext context) {
    final (gpsIcon, gpsLabel, gpsAlpha) = locationOff
        ? (Icons.gps_off_rounded, context.l10n.cameraGpsOff, 0.6)
        : accuracy == null
        ? (Icons.gps_not_fixed_rounded, context.l10n.cameraGpsSearching, 0.6)
        : (
            accuracy! <= _goodAccuracy ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
            context.l10n.cameraGps(accuracy!.round()),
            1.0,
          );
    return Row(
      children: [
        for (final trait in sky) ...[_overlayIcon(context, trait), const SizedBox(width: Gaps.l)],
        const Spacer(),
        _Glyph(icon: gpsIcon, label: gpsLabel, size: _size, alpha: gpsAlpha),
      ],
    );
  }

  Widget _overlayIcon(BuildContext context, Trait trait) {
    final label = context.game.trait(trait);
    final emoji = label.split(' ').first;
    return _Glyph(
      icon: traitIconOf(emoji) ?? Icons.eco_outlined,
      label: label,
      size: _size,
      mirrored: traitIconMirrored(emoji),
    );
  }
}

/// Precisione del GPS da stazione: sotto questa il segno è pieno. Provvisoria: si tara con la prova sul campo.
const _goodAccuracy = 15.0;

/// Un'icona sospesa sull'immagine, chiara con un'ombra morbida perché si legga su qualsiasi sfondo.
class _Glyph extends StatelessWidget {
  final IconData icon;
  final String label;
  final double size;
  final double alpha;
  final bool mirrored;

  const _Glyph({required this.icon, required this.label, required this.size, this.alpha = 1, this.mirrored = false});

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(
      icon,
      size: size,
      semanticLabel: label,
      color: context.colors.onSurface.withValues(alpha: alpha),
      shadows: [Shadow(color: context.colors.scrim.withValues(alpha: 0.7), blurRadius: 8)],
    );
    return Tooltip(
      message: label,
      child: mirrored ? Transform.flip(flipX: true, child: glyph) : glyph,
    );
  }
}

/// I gradini dello zoom: quello in uso mostra lo zoom vero (anche fra un gradino e l'altro, dopo un pizzico).
class _ZoomStops extends StatelessWidget {
  final List<double> stops;
  final double zoom;
  final ValueChanged<double> onSelected;

  const _ZoomStops({required this.stops, required this.zoom, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final active = stops.lastWhere((stop) => zoom >= stop - 0.05, orElse: () => stops.first);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.scrim.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Gaps.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final stop in stops)
              Semantics(
                button: true,
                selected: stop == active,
                label: context.l10n.cameraZoom(zoomLabel(stop)),
                child: GestureDetector(
                  key: ValueKey('camera-zoom-${zoomLabel(stop)}'),
                  onTap: () => onSelected(stop),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stop == active ? context.colors.surface.withValues(alpha: 0.7) : null,
                    ),
                    child: ExcludeSemantics(
                      child: Text(
                        zoomLabel(stop == active ? zoom : stop),
                        style: context.texts.labelMedium?.copyWith(
                          color: stop == active ? context.colors.primary : context.colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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

/// Le tre foto della pianta: intera, foglia, fiore. Quelle fatte sono piene, quella da fare è evidenziata.
class _OrganSteps extends StatelessWidget {
  final int done;

  const _OrganSteps({required this.done});

  @override
  Widget build(BuildContext context) {
    final labels = [context.l10n.cameraOrganWhole, context.l10n.cameraOrganLeaf, context.l10n.cameraOrganFlower];
    const icons = [Icons.park_rounded, Icons.eco_rounded, Icons.local_florist_rounded];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final organ in PlantOrgan.values) ...[
          if (organ.index > 0) const SizedBox(width: Gaps.xl),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _Glyph(
                icon: icons[organ.index],
                label: labels[organ.index],
                size: 26,
                alpha: organ.index < done
                    ? 1
                    : organ.index == done
                    ? 0.9
                    : 0.35,
              ),
              if (organ.index < done)
                Positioned(
                  right: -8,
                  bottom: -6,
                  child: Icon(Icons.check_circle_rounded, size: 16, color: context.colors.primary),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Un'indicazione breve sopra l'immagine, chiara con un'ombra come le icone.
class _Hint extends StatelessWidget {
  final String text;

  const _Hint(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    key: const ValueKey('camera-hint'),
    textAlign: TextAlign.center,
    style: context.texts.titleSmall?.copyWith(
      color: context.colors.onSurface,
      shadows: [Shadow(color: context.colors.scrim.withValues(alpha: 0.8), blurRadius: 8)],
    ),
  );
}

/// Pulsante di scatto che si riempie come se immagazzinasse la Vis: un anello cresce attorno e, pieno, il pulsante
/// diventa rosso (capitolo 05). Con la Vis debole accettata resta pallido ma scatta.
class _Shutter extends StatelessWidget {
  static const _size = 80.0;

  final double progress;
  final bool full;
  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;
  final VoidCallback onLocked;

  const _Shutter({
    required this.progress,
    required this.full,
    required this.enabled,
    required this.busy,
    required this.onPressed,
    required this.onLocked,
  });

  @override
  Widget build(BuildContext context) {
    final light = context.colors.onSurface;
    final core = full ? context.colors.error : light.withValues(alpha: enabled ? 0.85 : 0.3);
    return Semantics(
      button: true,
      enabled: enabled,
      label: context.l10n.cameraShutter,
      value: '${(progress * 100).round()} %',
      child: GestureDetector(
        key: const ValueKey('camera-shutter'),
        onTap: enabled ? onPressed : onLocked,
        child: SizedBox.square(
          dimension: _size,
          child: CustomPaint(
            painter: _RingPainter(progress: progress, track: light.withValues(alpha: 0.3), fill: light),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: busy
                  ? CircularProgressIndicator(color: light)
                  : AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: core),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// L'anello della Vis: la traccia intera e, sopra, l'arco già raccolto (da mezzogiorno, in senso orario).
class _RingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color fill;

  const _RingPainter({required this.progress, required this.track, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, paint..color = track);
    if (progress > 0) canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint..color = fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.track != track || old.fill != fill;
}
