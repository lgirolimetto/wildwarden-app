import 'package:druid_app/business_logic/models/weather_forecast.dart';
import 'package:druid_app/business_logic/rules/field/suspension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final noon = DateTime.utc(2027, 6, 14, 12);
  WeatherForecast forecast(Map<int, ForecastHour Function(DateTime)> hours) => WeatherForecast(
    fetchedAt: noon,
    hours: [
      for (var h = 8; h < 22; h++)
        (hours[h] ?? (t) => ForecastHour(time: t, weatherCode: 1))(DateTime.utc(2027, 6, 14, h)),
    ],
  );
  ForecastHour storm(DateTime t) => ForecastHour(time: t, weatherCode: 95);

  test('fenomeni intensi: temporale, grandine, raffiche oltre 60 km/h, neve forte', () {
    expect(severeOf(ForecastHour(time: noon, weatherCode: 95)), SevereWeather.storm);
    expect(severeOf(ForecastHour(time: noon, weatherCode: 99)), SevereWeather.hail);
    expect(severeOf(ForecastHour(time: noon, weatherCode: 3, windGusts: 65)), SevereWeather.wind);
    expect(severeOf(ForecastHour(time: noon, weatherCode: 75)), SevereWeather.snow);
    expect(severeOf(ForecastHour(time: noon, weatherCode: 71, snowfall: 2.5)), SevereWeather.snow);
    expect(severeOf(ForecastHour(time: noon, weatherCode: 63, windGusts: 40)), isNull, reason: 'pioggia: si Attinge');
  });

  test('temporale dalle 15 alle 17: sospesa dalle 14 alle 18, poi si riprende', () {
    final f = forecast({15: storm, 16: storm});
    expect(suspensionAt(f, DateTime.utc(2027, 6, 14, 13, 59)), isNull);
    final during = suspensionAt(f, DateTime.utc(2027, 6, 14, 14));
    expect(during?.reason, SevereWeather.storm);
    expect(during?.until, DateTime.utc(2027, 6, 14, 18));
    expect(suspensionAt(f, DateTime.utc(2027, 6, 14, 17, 59)), isNotNull);
    expect(suspensionAt(f, DateTime.utc(2027, 6, 14, 18)), isNull);
  });

  test('due temporali vicini fanno una sospensione sola', () {
    final f = forecast({13: storm, 15: storm});
    expect(suspensionAt(f, DateTime.utc(2027, 6, 14, 14, 30))?.until, DateTime.utc(2027, 6, 14, 17));
  });

  test("l'avviso guarda le prossime 6 ore", () {
    final f = forecast({19: storm});
    expect(upcomingSuspension(f, noon)?.until, DateTime.utc(2027, 6, 14, 21));
    expect(upcomingSuspension(f, DateTime.utc(2027, 6, 14, 9)), isNull, reason: 'oltre le 6 ore');
    expect(upcomingSuspension(forecast({}), noon), isNull);
  });
}
