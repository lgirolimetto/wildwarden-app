import 'package:druid_app/business_logic/models/enums/trait.dart';
import 'package:druid_app/l10n/app_localizations_it.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('icone delle lune', () {
    test('nel tema scuro restano come negli ARB', () {
      final texts = GameTexts(AppLocalizationsIt(), 'it', brightness: Brightness.dark);
      expect(texts.trait(Trait.moon), '🌕 Luna piena');
      expect(texts.trait(Trait.newMoon), '🌑 Luna nuova');
      expect(texts.trait(Trait.waxingMoon), '🌓 Luna crescente');
      expect(texts.trait(Trait.waningMoon), '🌗 Luna calante');
    });

    test('nel tema chiaro si scambiano: piena con nuova, crescente con calante', () {
      final texts = GameTexts(AppLocalizationsIt(), 'it', brightness: Brightness.light);
      expect(texts.trait(Trait.moon), '🌑 Luna piena');
      expect(texts.trait(Trait.newMoon), '🌕 Luna nuova');
      expect(texts.trait(Trait.waxingMoon), '🌗 Luna crescente');
      expect(texts.trait(Trait.waningMoon), '🌓 Luna calante');
    });

    test('gli altri tratti non cambiano', () {
      final light = GameTexts(AppLocalizationsIt(), 'it', brightness: Brightness.light);
      final dark = GameTexts(AppLocalizationsIt(), 'it', brightness: Brightness.dark);
      for (final t in Trait.values.where((t) => t.group != TraitGroup.moon)) {
        expect(light.trait(t), dark.trait(t));
      }
    });
  });
}
