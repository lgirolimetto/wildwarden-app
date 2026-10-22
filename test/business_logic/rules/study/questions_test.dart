import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/business_logic/services/catalog/asset_catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late Catalog small;

  setUp(() => small = smallCatalog());

  group('fatti per livello', () {
    test('elleboro: tutti e sei i fatti (ha parenti, stagione e quota nette)', () {
      final facts = factsOf(small.speciesBySci('Helleborus viridis')!, small).map((f) => f.kind);
      expect(facts, FactKind.values);
    });

    test('malva: niente parenti né stagione nel catalogo ridotto', () {
      final facts = factsOf(small.speciesBySci('Malva sylvestris')!, small).map((f) => f.kind);
      expect(facts, isNot(contains(FactKind.relatives)));
      expect(facts, isNot(contains(FactKind.season)));
      expect(facts, contains(FactKind.altitude));
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
      // Nel catalogo ridotto mancano solo le forme che richiedono più parenti o più specie.
      expect(
        seen,
        containsAll([
          QuestionForm.photoToName,
          QuestionForm.nameToPhoto,
          QuestionForm.sciToCommon,
          QuestionForm.commonToSci,
          QuestionForm.familyFromPhoto,
          QuestionForm.relativeOf,
          QuestionForm.seasonOf,
          QuestionForm.bandOf,
        ]),
      );
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
      final q = buildQuestion(Fact(species, FactKind.appearance), small, Random(3), avoid: QuestionForm.nameToPhoto);
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
            final q = buildQuestion(fact, catalog, random);
            seen.add(q.form);
            expect(q.options, contains(q.answer));
            // Le fasce di quota sono solo tre; per il resto, con 50 specie ci sono sempre 3 risposte sbagliate.
            expect(q.options.length, q.form == QuestionForm.bandOf ? 3 : 4, reason: '${q.form}');
          }
        }
      }
      expect(seen, QuestionForm.values.toSet());
    });
  });
}
