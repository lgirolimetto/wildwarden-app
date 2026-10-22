/// Configurazione per ambiente, letta dai `--dart-define` (vedi `env/*.example.json`).
class AppConfig {
  final String flavor;

  /// Chiave Pl@ntNet. ⚠️ Dentro l'app va bene solo finché l'app gira sul telefono dello sviluppatore:
  /// con altri utenti la chiave si sposta sul server.
  final String plantNetApiKey;
  final bool logHttp;

  /// Strumenti di prova nella UI (es. "Simula incontro"). Solo in sviluppo.
  final bool showDebugTools;

  const AppConfig({
    required this.flavor,
    required this.plantNetApiKey,
    required this.logHttp,
    required this.showDebugTools,
  });

  factory AppConfig.fromEnvironment({required String flavor}) => AppConfig(
    flavor: flavor,
    plantNetApiKey: const String.fromEnvironment('PLANTNET_API_KEY'),
    logHttp: const bool.fromEnvironment('LOG_HTTP'),
    showDebugTools: flavor == 'sviluppo',
  );
}
