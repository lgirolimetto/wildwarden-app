/// Un'Essenza attinta, nella Dispensa: la specie, i tratti veri in quel momento, la purezza (dal livello di studio
/// della specie quando l'hai attinta) e le Vis che restano (le consumano riciclo e pozioni).
class Essence {
  /// Posizione tra le Essenze attinte (0 = la prima): id stabile, perché le Essenze si rileggono dagli eventi.
  final int index;
  final String speciesSci;

  /// Id dei tratti (`Trait.name`); vuoto = nessun tratto.
  final List<String> traits;

  /// Da 0,4 (specie mai studiata) a 1,0 (maestria).
  final double purity;

  /// Vis che restano.
  final int vis;
  final DateTime drawnAt;

  const Essence({
    required this.index,
    required this.speciesSci,
    required this.traits,
    required this.purity,
    required this.vis,
    required this.drawnAt,
  });

  Essence withVis(int vis) =>
      Essence(index: index, speciesSci: speciesSci, traits: traits, purity: purity, vis: vis, drawnAt: drawnAt);
}
