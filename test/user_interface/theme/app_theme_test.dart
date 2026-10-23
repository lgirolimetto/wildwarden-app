import 'package:druid_app/user_interface/theme/app_theme.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/livery_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ogni livrea registrata deve produrre un tema completo, chiaro e scuro: aggiungere una livrea
/// alla `LiveryRegistry` basta per farla verificare da questi test.
void main() {
  test('gli id delle livree sono unici', () {
    final ids = LiveryRegistry.all.map((l) => l.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  for (final livery in LiveryRegistry.all) {
    for (final brightness in Brightness.values) {
      group('${livery.id} / ${brightness.name}', () {
        late ThemeData theme;

        setUp(() => theme = buildTheme(livery, brightness));

        test('luminosità coerente', () => expect(theme.colorScheme.brightness, brightness));

        test('contiene i token di gioco, con 5 colori di livello', () {
          final tokens = theme.extension<DruidTokens>();
          expect(tokens, isNotNull);
          expect(tokens!.levelColors, hasLength(5));
        });

        test('il testo principale si legge sullo sfondo (contrasto ≥ 4.5)', () {
          expect(_contrast(theme.colorScheme.onSurface, theme.colorScheme.surface), greaterThanOrEqualTo(4.5));
        });
      });
    }
  }

  test('i token si interpolano durante il cambio di tema', () {
    final a = buildTheme(LiveryRegistry.all.first, Brightness.light).extension<DruidTokens>()!;
    final b = buildTheme(LiveryRegistry.all.last, Brightness.dark).extension<DruidTokens>()!;
    final mid = a.lerp(b, 0.5);
    expect(mid.cardRadius, (a.cardRadius + b.cardRadius) / 2);
  });

  test('tema denso: Feltro di sera schiarisce sfondo e superfici; le altre combinazioni non ne hanno', () {
    final feltro = LiveryRegistry.byId('feltro');
    final normal = buildTheme(feltro, Brightness.dark);
    final dense = buildDenseTheme(feltro, Brightness.dark)!;
    expect(dense.colorScheme.surface, isNot(normal.colorScheme.surface));
    expect(dense.colorScheme.surfaceContainerLow, isNot(normal.colorScheme.surfaceContainerLow));
    expect(dense.extension<DruidTokens>()!.backgroundGradient.first, dense.colorScheme.surface);
    expect(buildDenseTheme(feltro, Brightness.light), isNull);
    for (final livery in LiveryRegistry.all.where((l) => l.id != 'feltro')) {
      expect(buildDenseTheme(livery, Brightness.dark), isNull, reason: livery.id);
    }
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
