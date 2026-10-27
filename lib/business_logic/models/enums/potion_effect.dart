/// Effetti delle pozioni: ognuno è una meccanica di gioco vera (capitolo 02, "Ricette ad affissi e pagine per
/// pianta"). Danno il suffisso al nome della ricetta ("della Ricrescita") e la vocazione alle piante.
///
/// ⚠️ Il nome di ogni valore è l'id usato nel catalogo: non si rinomina.
enum PotionEffect {
  /// La stazione dove la usi torna pronta prima.
  regrowth,

  /// Purezza in più alla prossima essenza.
  clarity,

  /// Un tratto garantito alla prossima essenza.
  omen,

  /// Vis in più alla prossima essenza.
  abundance,
}
