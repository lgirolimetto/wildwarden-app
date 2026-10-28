/// Registro delle prove sul campo (step 0 del blocco 2): un CSV che si scarica dal telefono con `adb`.
abstract interface class IFieldTestLog {
  /// Dove sta il file, da mostrare nella pagina di prova.
  Future<String> location();

  Future<void> append(String header, String row);

  Future<String> readAll();

  Future<void> clear();
}
