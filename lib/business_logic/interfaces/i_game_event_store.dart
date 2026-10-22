import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/models/game_event.dart';

/// Registro degli eventi di gioco. Oggi sta nel database del telefono; con il backend gli stessi eventi
/// verranno anche inviati al server.
abstract interface class IGameEventStore {
  /// Tutti gli eventi, dal più vecchio al più recente.
  Future<Validation<List<GameEvent>>> loadAll();

  Future<Validation<GameEvent>> append(GameEvent event);

  /// Cancella tutti gli eventi. Solo per gli strumenti di debug ("Azzera i progressi").
  Future<Validation<int>> clear();
}
