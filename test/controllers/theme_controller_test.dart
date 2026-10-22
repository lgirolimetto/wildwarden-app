import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:druid_app/user_interface/theme/liveries/notturna_livery.dart';
import 'package:druid_app/user_interface/theme/livery_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  test('senza preferenze: livrea di default e modalità di sistema', () {
    final controller = ThemeController(InMemoryPreferences())..onInit();

    expect(controller.livery.id, LiveryRegistry.fallback.id);
    expect(controller.mode, ThemeMode.system);
  });

  test('legge le preferenze salvate', () {
    final prefs = InMemoryPreferences({ThemeController.liveryKey: 'notturna', ThemeController.modeKey: 'dark'});
    final controller = ThemeController(prefs)..onInit();

    expect(controller.livery.id, 'notturna');
    expect(controller.mode, ThemeMode.dark);
  });

  test('una livrea sconosciuta nelle preferenze ripiega sul default', () {
    final controller = ThemeController(InMemoryPreferences({ThemeController.liveryKey: 'sparita'}))..onInit();

    expect(controller.livery.id, LiveryRegistry.fallback.id);
  });

  test('cambiare livrea ricostruisce i temi e salva la scelta', () async {
    final prefs = InMemoryPreferences();
    final controller = ThemeController(prefs)..onInit();
    final before = controller.lightTheme.colorScheme.primary;

    await controller.selectLivery(const NotturnaLivery());

    expect(controller.lightTheme.colorScheme.primary, isNot(before));
    expect(prefs.values[ThemeController.liveryKey], 'notturna');
  });

  test('cambiare modalità salva la scelta', () async {
    final prefs = InMemoryPreferences();
    final controller = ThemeController(prefs)..onInit();

    await controller.selectMode(ThemeMode.light);

    expect(prefs.values[ThemeController.modeKey], 'light');
  });
}
