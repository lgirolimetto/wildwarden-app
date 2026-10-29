import 'dart:io';

import 'package:druid_app/business_logic/interfaces/i_field_test_log.dart';
import 'package:path_provider/path_provider.dart';

/// Il CSV sta nella cartella esterna dell'app (`/sdcard/Android/data/<pacchetto>/files`), che `adb pull` legge anche
/// da una build release; se non c'è (iOS), nei documenti dell'app.
class FileFieldTestLog implements IFieldTestLog {
  static const fileName = 'prova_sul_campo.csv';

  Future<File> _file() async {
    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  @override
  Future<String> location() async => (await _file()).path;

  @override
  Future<void> append(String header, String row) async {
    final file = await _file();
    final exists = await file.exists();
    await file.writeAsString('${exists ? '' : '$header\n'}$row\n', mode: FileMode.append, flush: true);
  }

  @override
  Future<String> readAll() async {
    final file = await _file();
    return await file.exists() ? file.readAsString() : '';
  }

  @override
  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) await file.delete();
  }
}
