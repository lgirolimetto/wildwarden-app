/// Stagioni meteorologiche dell'emisfero nord.
///
/// ⚠️ Per l'emisfero sud i mesi vanno invertiti: oggi il catalogo copre solo Bologna.
enum Season {
  winter(months: [12, 1, 2]),
  spring(months: [3, 4, 5]),
  summer(months: [6, 7, 8]),
  autumn(months: [9, 10, 11]);

  const Season({required this.months});

  final List<int> months;

  static Season fromId(String id) => Season.values.byName(id);

  static Season ofMonth(int month) => Season.values.firstWhere((s) => s.months.contains(month));
}
