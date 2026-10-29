/// Le foto di chi gioca salvate sul telefono: la foto di ogni stazione.
///
/// Negli eventi si salva il percorso relativo alla cartella dei documenti, che può cambiare tra un'installazione e
/// l'altra (su iOS cambia a ogni aggiornamento).
abstract interface class IPhotoStore {
  /// Il percorso da salvare negli eventi.
  String relative(String path);

  /// Il file sul telefono di un percorso salvato negli eventi.
  String absolute(String relative);

  /// Cancella le foto che non servono più (le altre foto della sessione, gli scatti senza stazione).
  Future<void> delete(Iterable<String> paths);
}
