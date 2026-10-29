import 'package:druid_app/user_interface/pages/camera/camera_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gradini dello zoom fino al massimo della fotocamera', () {
    expect(zoomStops(10), [1, 2, 5]);
    expect(zoomStops(4), [1, 2]);
    expect(zoomStops(1), [1]);
  });

  test('lo zoom come lo scrivono le fotocamere', () {
    expect(zoomLabel(1), '1×');
    expect(zoomLabel(2.0), '2×');
    expect(zoomLabel(2.44), '2.4×');
    expect(zoomLabel(4.96), '5×');
  });
}
