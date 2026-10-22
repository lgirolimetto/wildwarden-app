/// Fasce di quota usate per indizi e domande.
enum AltitudeBand {
  plain(maxMeters: 150),
  hill(maxMeters: 600),
  mountain(maxMeters: null);

  const AltitudeBand({required this.maxMeters});

  /// Limite superiore escluso; `null` per l'ultima fascia.
  final int? maxMeters;

  static AltitudeBand fromId(String id) => AltitudeBand.values.byName(id);

  static AltitudeBand ofElevation(double meters) =>
      AltitudeBand.values.firstWhere((b) => b.maxMeters == null || meters < b.maxMeters!);
}
