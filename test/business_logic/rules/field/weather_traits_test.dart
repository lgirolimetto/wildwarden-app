import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/business_logic/models/weather_now.dart';
import 'package:druid_app/business_logic/rules/field/sky.dart';
import 'package:druid_app/business_logic/rules/field/weather_traits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const lat = 44.4937, lon = 11.3430;
  final noon = DateTime.utc(2026, 10, 28, 11);

  WeatherNow weather({
    DateTime? time,
    double temperature = 14,
    double dewPoint = 8,
    double precipitation = 0,
    int code = 0,
    double cloud = 10,
    double? visibility = 20000,
    bool isDay = true,
    List<WeatherHour> past = const [],
  }) => WeatherNow(
    time: time ?? noon,
    temperature: temperature,
    dewPoint: dewPoint,
    precipitation: precipitation,
    weatherCode: code,
    cloudCover: cloud,
    windSpeed: 5,
    visibility: visibility,
    isDay: isDay,
    pastHours: past,
  );

  test('sereno di giorno: Solare; nuvoloso o di notte no', () {
    expect(weatherTraits(weather(), lat, lon), [Trait.sun]);
    expect(weatherTraits(weather(cloud: 80), lat, lon), isEmpty);
    expect(weatherTraits(weather(isDay: false), lat, lon), isEmpty);
  });

  test('pioggia dal codice o dai millimetri, mai con il temporale', () {
    expect(weatherTraits(weather(code: 61, cloud: 100), lat, lon), [Trait.rain]);
    expect(weatherTraits(weather(precipitation: 0.4, cloud: 100), lat, lon), [Trait.rain]);
    expect(weatherTraits(weather(code: 95, precipitation: 6, cloud: 100), lat, lon), isEmpty);
    expect(isStorm(weather(code: 95)), isTrue);
  });

  test('nebbia dal codice o dalla visibilità; sotto zero Gelo', () {
    expect(weatherTraits(weather(code: 45, cloud: 100), lat, lon), [Trait.fog]);
    expect(weatherTraits(weather(visibility: 400, cloud: 100), lat, lon), [Trait.fog]);
    expect(weatherTraits(weather(temperature: -2, dewPoint: -4), lat, lon), [Trait.sun, Trait.frost]);
  });

  group('Rugiada', () {
    final sun = sunTimes(DateTime(2026, 10, 28), lat, lon)!;
    List<WeatherHour> night({double spread = 1, double cloud = 10}) => [
      for (var h = 8; h >= 1; h--)
        WeatherHour(
          time: sun.sunrise.subtract(Duration(hours: h)),
          temperature: 6,
          dewPoint: 6 - spread,
          cloudCover: cloud,
          windSpeed: 3,
        ),
    ];

    test('dopo una notte fresca e serena, dalle prime luci a 2 ore dopo il sorgere', () {
      final morning = sun.sunrise.add(const Duration(minutes: 30));
      expect(weatherTraits(weather(time: morning, past: night()), lat, lon), contains(Trait.dew));
      final late = sun.sunrise.add(const Duration(hours: 2, minutes: 5));
      expect(weatherTraits(weather(time: late, past: night()), lat, lon), isNot(contains(Trait.dew)));
    });

    test('notte nuvolosa o asciutta: niente Rugiada', () {
      final morning = sun.sunrise.add(const Duration(minutes: 30));
      expect(weatherTraits(weather(time: morning, past: night(cloud: 90)), lat, lon), isNot(contains(Trait.dew)));
      expect(weatherTraits(weather(time: morning, past: night(spread: 5)), lat, lon), isNot(contains(Trait.dew)));
    });
  });
}
