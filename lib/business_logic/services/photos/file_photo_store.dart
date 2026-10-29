import 'dart:io';

import 'package:druid_app/business_logic/interfaces/i_photo_store.dart';
import 'package:path_provider/path_provider.dart';

/// Le foto nella cartella dei documenti dell'app (dove le salva il mirino, in `photos/`).
class FilePhotoStore implements IPhotoStore {
  final String _root;

  FilePhotoStore(this._root);

  static Future<FilePhotoStore> create() async => FilePhotoStore((await getApplicationDocumentsDirectory()).path);

  @override
  String relative(String path) => path.startsWith('$_root/') ? path.substring(_root.length + 1) : path;

  @override
  String absolute(String relative) => relative.startsWith('/') ? relative : '$_root/$relative';

  @override
  Future<void> delete(Iterable<String> paths) async {
    for (final path in paths) {
      try {
        await File(absolute(path)).delete();
      } on FileSystemException {
        // Già cancellata: niente da fare.
      }
    }
  }
}
