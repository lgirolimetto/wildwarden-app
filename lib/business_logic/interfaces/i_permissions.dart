import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';

/// Com'è un permesso dopo la richiesta.
enum PermissionOutcome {
  granted,

  /// Solo per la posizione: concessa ma approssimativa (Android 12+): le Stazioni non sarebbero precise.
  approximate,
  denied,

  /// Negato per sempre: si riattiva solo dalle impostazioni di Android.
  deniedForever,
}

/// I permessi della fotocamera e della posizione, chiesti nell'onboarding di primo avvio dopo averli spiegati.
abstract interface class IPermissions {
  Future<Validation<PermissionOutcome>> requestCamera();

  /// Il permesso della posizione e, se serve, la finestra di sistema della precisione.
  Future<Validation<PermissionOutcome>> requestLocation();

  /// Apre le impostazioni dell'app in Android, per dare un permesso negato per sempre.
  Future<Validation<bool>> openAppSettings();
}
