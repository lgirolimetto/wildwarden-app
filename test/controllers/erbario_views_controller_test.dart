import 'package:druid_app/business_logic/rules/erbario_views.dart';
import 'package:druid_app/controllers/erbario/erbario_views_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  test('una vista salvata resta dopo il riavvio, e resta scelta', () async {
    final prefs = InMemoryPreferences();
    final first = ErbarioViewsController(prefs)..onInit();
    final view = await first.add('Solo protette', const ErbarioFilter(protectedOnly: true));
    expect(first.selected, view.id);

    final again = ErbarioViewsController(prefs)..onInit();
    expect(again.saved.map((v) => v.name), ['Solo protette']);
    expect(again.selected, view.id);
    expect(again.filter.protectedOnly, isTrue);
  });

  test('eliminare la vista scelta torna a "Tutte"', () async {
    final controller = ErbarioViewsController(InMemoryPreferences())..onInit();
    final view = await controller.add('Prova', const ErbarioFilter(inSeason: true));
    await controller.remove(view.id);
    expect(controller.saved, isEmpty);
    expect(controller.selected, ErbarioViewsController.builtInKey(BuiltInView.all));
  });

  test('preferenze rovinate: nessuna vista, nessun errore', () {
    final controller = ErbarioViewsController(InMemoryPreferences({ErbarioViewsController.viewsKey: 'non json'}))
      ..onInit();
    expect(controller.saved, isEmpty);
  });
}
