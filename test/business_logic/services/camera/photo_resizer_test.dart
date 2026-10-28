import 'dart:typed_data';

import 'package:druid_app/business_logic/services/camera/photo_resizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  img.Image decode(Uint8List bytes) => img.decodeJpg(bytes)!;

  test('una foto grande scende a 1600 px sul lato lungo, in orizzontale e in verticale', () {
    final landscape = decode(resizeJpeg(img.encodeJpg(img.Image(width: 4000, height: 3000))));
    expect((landscape.width, landscape.height), (1600, 1200));

    final portrait = decode(resizeJpeg(img.encodeJpg(img.Image(width: 3000, height: 4000))));
    expect((portrait.width, portrait.height), (1200, 1600));
  });

  test('una foto piccola non si ingrandisce', () {
    final small = decode(resizeJpeg(img.encodeJpg(img.Image(width: 800, height: 600))));
    expect((small.width, small.height), (800, 600));
  });

  test('una foto non leggibile è un errore', () {
    expect(() => resizeJpeg(Uint8List.fromList([1, 2, 3])), throwsFormatException);
  });

  test('anche in un isolate', () async {
    final resized = decode(await resizeJpegInBackground(img.encodeJpg(img.Image(width: 2000, height: 1000))));
    expect((resized.width, resized.height), (1600, 800));
  });
}
