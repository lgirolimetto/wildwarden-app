import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/models/species_traits.dart';
import 'package:druid_app/business_logic/rules/species_rules.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/business_logic/services/catalog/asset_catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late Catalog small;

  setUp(() => small = smallCatalog());

  group('fatti per livello', () {
    test('elleboro: tutti i fatti attivi (ha parenti, quota netta e tutti i tratti)', () {
      final facts = factsOf(small.speciesBySci('Helleborus viridis')!, small).map((f) => f.kind);
      expect(facts.toSet(), FactKind.values.where((k) => !k.retired).toSet());
    });

    test('malva: niente parenti nel catalogo ridotto, niente ciclo vitale (WCVP incerto: biennale o perenne)', () {
      final facts = factsOf(small.speciesBySci('Malva sylvestris')!, small).map((f) => f.kind);
      expect(facts, isNot(contains(FactKind.relatives)));
      expect(facts, isNot(contains(FactKind.lifeCycle)));
      expect(facts, containsAll([FactKind.altitude, FactKind.growthForm, FactKind.light, FactKind.seedDispersal]));
    });

    test('la tossicità non si chiede più, nemmeno per le specie con l\'avviso', () {
      final facts = factsOf(small.speciesBySci('Helleborus viridis')!, small).map((f) => f.kind);
      expect(small.safety, contains('Helleborus viridis'));
      expect(facts, isNot(contains(FactKind.toxicity)));
    });

    test('nome comune e stagione sono ritirati: non si chiedono più', () {
      for (final species in small.species) {
        final kinds = factsOf(species, small).map((f) => f.kind);
        expect(kinds, isNot(contains(FactKind.name)));
        expect(kinds, isNot(contains(FactKind.season)));
      }
    });

    test('id del fatto: andata e ritorno', () {
      final parsed = Fact.parseId(Fact.idOf('Helleborus viridis', FactKind.season));
      expect(parsed.speciesSci, 'Helleborus viridis');
      expect(parsed.kind, FactKind.season);
    });
  });

  group('domande', () {
    test('ogni forma possibile produce una domanda valida, con la risposta tra le opzioni', () {
      final random = Random(1);
      final seen = <QuestionForm>{};
      for (final species in small.species) {
        for (final fact in factsOf(species, small)) {
          for (var i = 0; i < 20; i++) {
            final q = buildQuestion(fact, small, random);
            seen.add(q.form);
            expect(q.options, contains(q.answer), reason: '${fact.id} ${q.form}');
            expect(q.options.toSet(), hasLength(q.options.length), reason: 'opzioni duplicate in ${q.form}');
            expect(q.options.length, inInclusiveRange(2, 4));
            expect(q.isCorrect(q.answer), isTrue);
          }
        }
      }
      // Nel catalogo ridotto mancano solo le forme che richiedono più parenti, più specie o più avvisi.
      expect(
        seen,
        containsAll([
          QuestionForm.nameToPhoto,
          QuestionForm.commonToSci,
          QuestionForm.familyFromPhoto,
          QuestionForm.orderOf,
          QuestionForm.relativeOf,
          QuestionForm.bandOf,
          QuestionForm.commonnessOf,
          QuestionForm.growthFormOf,
          QuestionForm.lifeCycleOf,
          QuestionForm.seedDispersalOf,
          QuestionForm.originOf,
          QuestionForm.lightOf,
          QuestionForm.moistureOf,
        ]),
      );
    });

    test('studiando un livello non si chiede mai il nome comune (è nel titolo)', () {
      final random = Random(2);
      for (final species in small.species) {
        for (final fact in factsOf(species, small)) {
          for (var i = 0; i < 20; i++) {
            final form = buildQuestion(fact, small, random).form;
            expect(form, isNot(anyOf(QuestionForm.photoToName, QuestionForm.sciToCommon)), reason: fact.id);
          }
        }
      }
    });

    test('nei ripassi tornano le forme sul nome comune', () {
      final fact = Fact(small.speciesBySci('Fagus sylvatica')!, FactKind.appearance);
      final forms = {
        for (var seed = 0; seed < 30; seed++) buildQuestion(fact, small, Random(seed), mode: AnswerMode.review).form,
      };
      expect(forms, contains(QuestionForm.photoToName));
    });

    test('nome scientifico: prima le specie vere dello stesso genere', () {
      final malva = small.speciesBySci('Malva sylvestris')!;
      final q = buildQuestion(Fact(malva, FactKind.scientificName), small, Random(1));
      expect(q.answer, const ScientificNameOption('Malva sylvestris'));
      expect(
        q.options.where((o) => o != q.answer).map((o) => (o as ScientificNameOption).sci),
        everyElement(startsWith('Malva ')),
      );
    });

    test('nome scientifico senza sorelle: i nomi che suonano più simili, mai inventati', () {
      final faggio = small.speciesBySci('Fagus sylvatica')!;
      final known = {
        for (final s in small.species) ...[s.sci, ...s.congeners],
      };
      final names = similarScientificNames(faggio, small, Random(1));
      expect(names, hasLength(3));
      expect(known, containsAll(names));
      expect(names, isNot(contains('Fagus sylvatica')));
    });

    test('"Quale di queste è…?": la foto giusta non è la copertina dell\'erbario, se ce ne sono altre', () {
      final species = small.species.firstWhere((s) => s.images.length > 1);
      for (var seed = 0; seed < 20; seed++) {
        final q = buildQuestion(Fact(species, FactKind.appearance), small, Random(seed));
        expect(q.form, QuestionForm.nameToPhoto);
        expect((q.answer as SpeciesOption).imageUrl, isNot(species.images.first.url));
      }
    });

    test('con [avoid] si ottiene una forma diversa, se esiste', () {
      final fact = Fact(small.speciesBySci('Helleborus viridis')!, FactKind.family);
      for (var seed = 0; seed < 30; seed++) {
        final q = buildQuestion(fact, small, Random(seed), avoid: QuestionForm.familyFromCommon);
        expect(q.form, isNot(QuestionForm.familyFromCommon));
      }
    });

    test('le foto da riconoscere vengono dalla specie giusta', () {
      final species = small.speciesBySci('Fagus sylvatica')!;
      final q = buildQuestion(
        Fact(species, FactKind.appearance),
        small,
        Random(3),
        avoid: QuestionForm.nameToPhoto,
        mode: AnswerMode.review,
      );
      expect(q.form, QuestionForm.photoToName);
      expect(species.images.map((i) => i.url), contains(q.imageUrl));
    });

    test('sul catalogo reale di Bologna tutte le forme compaiono e sono valide', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final catalog = (await AssetCatalogRepository().loadCatalog()).fold((_) => fail('catalogo'), (c) => c);
      final random = Random(7);
      final seen = <QuestionForm>{};
      for (final species in catalog.species) {
        for (final fact in factsOf(species, catalog)) {
          for (var i = 0; i < 6; i++) {
            final q = buildQuestion(fact, catalog, random, mode: i.isEven ? AnswerMode.learning : AnswerMode.review);
            seen.add(q.form);
            expect(q.options, contains(q.answer));
            expect(q.options.toSet(), hasLength(q.options.length), reason: 'opzioni duplicate in ${q.form}');
            // Valori fissi: quota, ciclo, luce, umidità tre; origine due (sì/no); per il resto, con 50 specie ci sono
            // sempre 3 risposte sbagliate.
            final expected = switch (q.form) {
              QuestionForm.bandOf || QuestionForm.lifeCycleOf || QuestionForm.lightOf || QuestionForm.moistureOf => 3,
              QuestionForm.originOf => 2,
              _ => 4,
            };
            expect(q.options.length, expected, reason: '${q.form}');
          }
        }
      }
      expect(seen, QuestionForm.values.toSet());
    });
  });

  group('tratti', () {
    test('semi: la risposta è un modo della specie, le sbagliate modi che non usa', () {
      final elleboro = small.speciesBySci('Helleborus viridis')!;
      for (var seed = 0; seed < 10; seed++) {
        final q = buildQuestion(Fact(elleboro, FactKind.seedDispersal), small, Random(seed));
        expect(q.answer, const TraitOption(SeedDispersal.ants));
        expect(q.options.where((o) => o != q.answer), everyElement(isNot(const TraitOption(SeedDispersal.ants))));
      }
    });

    test('luce e umidità: soglie sugli indicatori EIVE', () {
      expect(lightPreferenceOf(small.speciesBySci('Fagus sylvatica')!), LightPreference.shade);
      expect(lightPreferenceOf(small.speciesBySci('Malva sylvestris')!), LightPreference.sun);
      expect(lightPreferenceOf(small.speciesBySci('Eranthis hyemalis')!), LightPreference.shade);
      expect(moisturePreferenceOf(small.speciesBySci('Malva sylvestris')!), MoisturePreference.fresh);
    });

    test('origine: domanda sì/no "arrivata da fuori?", la risposta segue WCVP', () {
      final faggio = small.speciesBySci('Fagus sylvatica')!;
      final q = buildQuestion(Fact(faggio, FactKind.origin), small, Random(1));
      expect(q.answer, const YesNoOption(false));
      expect(q.options, hasLength(2));
    });
  });
}
