import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_permissions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

/// Fotocamera con `permission_handler`, posizione con `geolocator` (lo stesso pacchetto che la legge nel mirino).
class DevicePermissions implements IPermissions {
  const DevicePermissions();

  @override
  Future<Validation<PermissionOutcome>> requestCamera() => _guard(() async {
    final status = await handler.Permission.camera.request();
    return status.isGranted
        ? PermissionOutcome.granted
        : status.isPermanentlyDenied
        ? PermissionOutcome.deniedForever
        : PermissionOutcome.denied;
  });

  @override
  Future<Validation<PermissionOutcome>> requestLocation() => _guard(() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return PermissionOutcome.deniedForever;
    if (permission == LocationPermission.denied || permission == LocationPermission.unableToDetermine) {
      return PermissionOutcome.denied;
    }
    // Una posizione alla massima precisione fa comparire la finestra di sistema della precisione (e quella per
    // accendere la posizione, se è spenta). Se non arriva entro il tempo massimo va bene lo stesso.
    try {
      await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(accuracy: LocationAccuracy.best, timeLimit: const Duration(seconds: 15)),
      );
    } on Exception {
      // Posizione lenta o spenta: il permesso c'è, il mirino la cercherà di nuovo.
    }
    final accuracy = await Geolocator.getLocationAccuracy();
    return accuracy == LocationAccuracyStatus.reduced ? PermissionOutcome.approximate : PermissionOutcome.granted;
  });

  @override
  Future<Validation<bool>> openAppSettings() => _guard(handler.openAppSettings);

  Future<Validation<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Valid(await action());
    } catch (e) {
      return Fail.withError(e is Error ? e : StateError('$e'), message: '$e').toInvalid();
    }
  }
}
