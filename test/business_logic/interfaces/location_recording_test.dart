import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le posizioni arrivano nella lista e nello stream fino allo stop, poi più niente', () async {
    var stops = 0;
    final recording = LocationRecording(() async => stops++);
    final updates = <double>[];
    recording.updates.listen((fix) => updates.add(fix.accuracy));

    recording.add(latitude: 44.5, longitude: 11.3, accuracy: 20);
    recording.add(latitude: 44.5, longitude: 11.3, accuracy: 8);
    await Future<void>.delayed(Duration.zero);
    final fixes = await recording.stop();
    recording.add(latitude: 44.5, longitude: 11.3, accuracy: 3);
    await recording.stop();

    expect(fixes.map((f) => f.accuracy), [20, 8]);
    expect(updates, [20, 8]);
    expect(stops, 1);
  });
}
