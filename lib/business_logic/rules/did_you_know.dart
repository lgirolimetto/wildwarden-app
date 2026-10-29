/// "Lo sapevi che…" (capitolo 02, 2026-10-24/26/28): avvisi brevi sulle regole, come toast in Home, uno al giorno,
/// senza ripetersi finché non li hai visti tutti; quello di una regola che entra in gioco (la prima raccolta sospesa)
/// compare subito, dove succede. Prima quelli di sicurezza.
enum DidYouKnow { storm, daylight, moon, noPicking, oneDrawPerDay, isolation }

/// Quale mostrare oggi: nessuno se oggi ne è già comparso uno; altrimenti il primo non ancora visto; visti tutti, si
/// ricomincia dal primo.
DidYouKnow? didYouKnowToday({required Set<DidYouKnow> seen, required DateTime? lastShown, required DateTime now}) {
  if (lastShown != null && lastShown.year == now.year && lastShown.month == now.month && lastShown.day == now.day) {
    return null;
  }
  for (final tip in DidYouKnow.values) {
    if (!seen.contains(tip)) return tip;
  }
  return DidYouKnow.values.first;
}
