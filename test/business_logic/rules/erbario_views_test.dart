import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/species_traits.dart';
import 'package:druid_app/business_logic/rules/erbario_views.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late Catalog catalog;
  final feb = DateTime(2027, 2, 14);

  setUp(
    () => catalog = smallCatalog(
      protection: {
        'Malva sylvestris': ['regional-emilia-romagna'],
      },
    ),
  );

  List<String> shown(ErbarioFilter filter, [GameState state = GameState.empty]) => [
    for (final s in catalog.species)
      if (filter.matches(s, state, feb)) s.sci,
  ];

  test('il filtro vuoto mostra tutto', () {
    expect(shown(ErbarioFilter.all), hasLength(catalog.species.length));
    expect(ErbarioFilter.all.isEmpty, isTrue);
  });

  test('in stagione: a febbraio elleboro e piè di gallo', () {
    expect(shown(BuiltInView.inSeason.filter), ['Helleborus viridis', 'Eranthis hyemalis']);
  });

  test('stato: incontrate, da trovare, desiderata, in studio', () {
    final state = GameState.replay([
      SpeciesEncountered(speciesSci: 'Fagus sylvatica', method: EncounterMethod.simulated, occurredAt: feb),
      DesiderataChanged(speciesSci: 'Malva sylvestris', marked: true, occurredAt: feb),
    ]);
    expect(shown(const ErbarioFilter(statuses: {SpeciesStatus.met}), state), ['Fagus sylvatica']);
    expect(shown(const ErbarioFilter(statuses: {SpeciesStatus.desiderata}), state), ['Malva sylvestris']);
    expect(shown(const ErbarioFilter(statuses: {SpeciesStatus.toFind}), state), hasLength(3));
    expect(shown(const ErbarioFilter(statuses: {SpeciesStatus.studying}), state), ['Fagus sylvatica']);
  });

  test('criteri insieme: tutti devono valere; dentro un criterio basta un valore', () {
    expect(shown(const ErbarioFilter(forms: {GrowthForm.tree})), ['Fagus sylvatica']);
    expect(shown(const ErbarioFilter(forms: {GrowthForm.tree, GrowthForm.herb})), hasLength(4));
    expect(shown(const ErbarioFilter(forms: {GrowthForm.herb}, protectedOnly: true)), ['Malva sylvestris']);
    expect(shown(const ErbarioFilter(families: {'Ranunculaceae'}, inSeason: true)), hasLength(2));
    expect(shown(const ErbarioFilter(bands: {AltitudeBand.mountain})), contains('Fagus sylvatica'));
  });

  test('vista salvata: andata e ritorno in JSON; valori sconosciuti ignorati', () {
    const view = SavedView(
      id: 'v1',
      name: 'Alberi di montagna',
      filter: ErbarioFilter(forms: {GrowthForm.tree}, bands: {AltitudeBand.mountain}, families: {'Fagaceae'}),
    );
    final back = SavedView.fromJson(view.toJson());
    expect(back.name, 'Alberi di montagna');
    expect(back.filter.forms, {GrowthForm.tree});
    expect(back.filter.bands, {AltitudeBand.mountain});
    expect(back.filter.families, {'Fagaceae'});
    expect(
      ErbarioFilter.fromJson({
        'forms': ['tree', 'cactus'],
      }).forms,
      {GrowthForm.tree},
    );
  });
}
