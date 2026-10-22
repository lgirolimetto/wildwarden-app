/// Orologio iniettabile: i test (e gli strumenti di debug) possono spostare il tempo,
/// indispensabile per ripassi e rigenerazione delle stazioni.
abstract interface class IClock {
  DateTime now();
}

class SystemClock implements IClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
