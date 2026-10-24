import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/diorama.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/theme/app_theme.dart';
import 'package:druid_app/user_interface/theme/livery.dart';
import 'package:druid_app/user_interface/theme/liveries/erbario_livery.dart';
import 'package:druid_app/user_interface/theme/liveries/feltro_livery.dart';
import 'package:druid_app/user_interface/theme/liveries/sottobosco_livery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child, {Livery livery = const SottoboscoLivery()}) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(livery, Brightness.light),
    home: Scaffold(body: Center(child: child)),
  ),
);

BoxDecoration _decorationOf(WidgetTester tester, Finder finder) =>
    tester.widget<DecoratedBox>(find.descendant(of: finder, matching: find.byType(DecoratedBox)).first).decoration
        as BoxDecoration;

void main() {
  group('momento del giorno', () {
    test('alba, giorno, tramonto e notte dalle ore', () {
      expect(DayTime.of(DateTime(2027, 1, 1, 6)), DayTime.dawn);
      expect(DayTime.of(DateTime(2027, 1, 1, 12)), DayTime.day);
      expect(DayTime.of(DateTime(2027, 1, 1, 19)), DayTime.dusk);
      expect(DayTime.of(DateTime(2027, 1, 1, 23)), DayTime.night);
      expect(DayTime.of(DateTime(2027, 1, 1, 2)), DayTime.night);
    });
  });

  testWidgets('il diorama si disegna in ogni stagione e momento del giorno', (tester) async {
    for (final season in Season.values) {
      final month = switch (season) {
        Season.winter => 1,
        Season.spring => 4,
        Season.summer => 7,
        Season.autumn => 10,
      };
      for (final hour in [6, 12, 19, 23]) {
        await _pump(
          tester,
          SizedBox(
            width: 400,
            height: 300,
            child: Diorama(moment: DateTime(2027, month, 10, hour), fadeTo: Colors.white),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$season alle $hour');
      }
    }
  });

  group('plastilina', () {
    testWidgets('con una livrea in plastilina la scheda ha ombre morbide e sfumatura', (tester) async {
      await _pump(tester, const ClayCard(key: ValueKey('card'), child: Text('x')));
      final decoration = _decorationOf(tester, find.byKey(const ValueKey('card')));
      expect(decoration.gradient, isNotNull);
      expect(decoration.boxShadow, hasLength(2));
    });

    testWidgets('con una livrea piatta la stessa scheda resta piatta', (tester) async {
      await _pump(
        tester,
        const ClayCard(key: ValueKey('card'), child: Text('x')),
        livery: const ErbarioLivery(),
      );
      final decoration = _decorationOf(tester, find.byKey(const ValueKey('card')));
      expect(decoration.gradient, isNull);
      expect(decoration.boxShadow, isNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('il pulsante risponde al tocco e, senza azione, è disattivato', (tester) async {
      var taps = 0;
      await _pump(tester, ClayButton(label: 'Vai', onPressed: () => taps++));
      await tester.tap(find.text('Vai'));
      await tester.pumpAndSettle();
      expect(taps, 1);

      await _pump(tester, const ClayButton(label: 'Fermo', onPressed: null));
      await tester.tap(find.text('Fermo'));
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, lessThan(1));
    });

    testWidgets('la barra di navigazione segnala la voce scelta', (tester) async {
      var selected = 0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => ClayNavBar(
            selectedIndex: selected,
            onSelected: (i) => setState(() => selected = i),
            items: const [(Icons.school, 'Studio'), (Icons.science, 'Ricette')],
          ),
        ),
      );
      await tester.tap(find.text('Ricette'));
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(find.descendant(of: find.byType(ClayNavBar), matching: find.byType(ClayCircle)), findsOneWidget);
    });

    testWidgets('nel neumorfismo la chip scelta è scavata (premuta), le altre in rilievo', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClayChip(label: 'Uno', selected: false, onTap: () => taps++),
            const ClayChip(label: 'Due', selected: true),
          ],
        ),
        livery: const FeltroLivery(),
      );
      expect(find.ancestor(of: find.text('Uno'), matching: find.byType(NeuInset)), findsNothing);
      expect(find.ancestor(of: find.text('Due'), matching: find.byType(NeuInset)), findsOneWidget);
      await tester.tap(find.text('Uno'));
      expect(taps, 1);
    });

    testWidgets('senza neumorfismo la chip resta una ChoiceChip', (tester) async {
      await _pump(tester, const ClayChip(label: 'Uno', selected: false));
      expect(find.byType(ChoiceChip), findsOneWidget);
    });

    testWidgets('linguette neumorfiche: binario scavato, la pillola scivola sulla linguetta scelta', (tester) async {
      var tab = 0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 300,
            child: ClayTabs(
              tabs: const [
                ClayTab(label: 'Uno'),
                ClayTab(label: 'Due'),
              ],
              selected: tab,
              onChanged: (t) => setState(() => tab = t),
            ),
          ),
        ),
        livery: const FeltroLivery(),
      );
      await tester.pumpAndSettle();
      expect(find.ancestor(of: find.text('Due'), matching: find.byType(NeuInset)), findsOneWidget);
      double pillLeft() => tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).left!;
      expect(pillLeft(), 0);

      await tester.tap(find.text('Due'));
      await tester.pumpAndSettle();
      expect(tab, 1);
      expect(pillLeft(), greaterThan(100), reason: 'la pillola è scivolata sulla seconda linguetta');
    });

    testWidgets('linguette che scorrono: la pillola scivola, pressione lunga, "+" fuori dal binario', (tester) async {
      var selected = 0;
      var longPressed = '';
      const labels = ['Tutte', 'In stagione adesso', 'Le mie Desiderata', 'Protette', 'Alberi'];
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 320,
            child: ClayTabs(
              scrollable: true,
              tabs: [for (final label in labels) ClayTab(label: label, onLongPress: () => longPressed = label)],
              selected: selected,
              onChanged: (i) => setState(() => selected = i),
              trailing: const Icon(Icons.add, key: ValueKey('plus')),
            ),
          ),
        ),
        livery: const FeltroLivery(),
      );
      await tester.pumpAndSettle();
      expect(find.ancestor(of: find.text('Tutte'), matching: find.byType(NeuInset)), findsOneWidget);
      expect(find.ancestor(of: find.byKey(const ValueKey('plus')), matching: find.byType(NeuInset)), findsNothing);
      // C'è altro da scorrere: all'inizio è accesa solo la freccina destra; toccata, il binario scorre.
      (bool, bool) arrows() => (
        tester.widget<ScrollHintArrow>(find.byKey(const ValueKey('more-left'))).enabled,
        tester.widget<ScrollHintArrow>(find.byKey(const ValueKey('more-right'))).enabled,
      );
      expect(arrows(), (false, true));
      final before = tester.getRect(find.text('Tutte')).left;
      await tester.tap(find.byKey(const ValueKey('more-right')));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('Tutte')).left, lessThan(before), reason: 'il binario è scorso a destra');
      expect(arrows().$1, isTrue, reason: 'ora c\'è altro anche a sinistra');

      await tester.ensureVisible(find.text('Alberi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alberi'));
      await tester.pumpAndSettle();
      expect(selected, 4);
      expect(arrows(), (true, false), reason: 'in fondo resta accesa solo la freccina sinistra');
      final pill = tester.getRect(find.byType(AnimatedPositioned));
      final alberi = tester.getRect(find.text('Alberi'));
      expect(pill.left, lessThan(alberi.left), reason: 'la pillola è sotto "Alberi"');
      expect(pill.right, greaterThan(alberi.right));

      await tester.longPress(find.text('Alberi'));
      expect(longPressed, 'Alberi');
    });

    testWidgets('senza neumorfismo le linguette sono un SegmentedButton', (tester) async {
      await _pump(
        tester,
        ClayTabs(
          tabs: const [
            ClayTab(label: 'Uno'),
            ClayTab(label: 'Due'),
          ],
          selected: 0,
          onChanged: (_) {},
        ),
      );
      expect(find.byType(SegmentedButton<int>), findsOneWidget);
    });

    testWidgets('interruttore neumorfico: tocco cambia valore, sfera a destra se acceso', (tester) async {
      var value = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => ClaySwitch(value: value, onChanged: (v) => setState(() => value = v)),
        ),
        livery: const FeltroLivery(),
      );
      expect(find.byType(NeuInset), findsOneWidget);
      await tester.tap(find.byType(ClaySwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).alignment, Alignment.centerRight);
    });

    testWidgets('fuori dal neumorfismo l\'interruttore è uno Switch', (tester) async {
      await _pump(tester, ClaySwitch(value: true, onChanged: (_) {}));
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('barra di avanzamento neumorfica: parte piena in proporzione, valori fuori scala limitati', (
      tester,
    ) async {
      await _pump(tester, const SizedBox(width: 200, child: ClayProgressBar(value: 0.4)), livery: const FeltroLivery());
      expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor, 0.4);
      await _pump(tester, const SizedBox(width: 200, child: ClayProgressBar(value: 1.7)), livery: const FeltroLivery());
      expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor, 1);
      await _pump(tester, const SizedBox(width: 200, child: ClayProgressBar(value: 0.4)));
      await tester.pumpAndSettle(); // il cambio di livrea è animato
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    test('emoji iniziale dei tratti', () {
      expect(leadingEmoji('🌕 Lunare'), '🌕');
      expect(leadingEmoji('❄️ Gelo'), '❄️');
      expect(leadingEmoji('Base'), isNull);
      expect(leadingEmoji(''), isNull);
    });
  });

  group('icone incise nelle livree neumorfiche', () {
    testWidgets('una chip con l\'emoji di un tratto mostra l\'icona incisa, senza emoji', (tester) async {
      await _pump(
        tester,
        ClayChip(label: '❄️ Gelo', onTap: () {}),
        livery: const FeltroLivery(),
      );
      expect(find.text('Gelo'), findsOneWidget);
      expect(find.textContaining('❄️'), findsNothing);
      expect(find.byType(EngravedIcon), findsOneWidget);
    });

    testWidgets('fuori dal neumorfismo la chip resta com\'è', (tester) async {
      await _pump(tester, ClayChip(label: '❄️ Gelo', onTap: () {}));
      expect(find.text('❄️ Gelo'), findsOneWidget);
      expect(find.byType(EngravedIcon), findsNothing);
    });

    testWidgets('una sfera con icona diventa incisa; con keepColor resta colorata', (tester) async {
      await _pump(
        tester,
        const Row(
          children: [
            ClayCircle(color: Colors.orange, icon: Icons.flag_rounded),
            ClayCircle(color: Colors.orange, icon: Icons.check_rounded, keepColor: true),
          ],
        ),
        livery: const FeltroLivery(),
      );
      expect(find.byType(EngravedIcon), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('regola del rilievo: un\'icona da guardare è incisa (solco), una da premere resta in rilievo', (
      tester,
    ) async {
      await _pump(
        tester,
        const Row(
          children: [
            ClayCircle(key: ValueKey('look'), color: Colors.orange, icon: Icons.flag_rounded),
            ClayCircle(key: ValueKey('press'), color: Colors.orange, icon: Icons.menu_book_rounded, pressable: true),
          ],
        ),
        livery: const FeltroLivery(),
      );
      expect(find.descendant(of: find.byKey(const ValueKey('look')), matching: find.byType(NeuInset)), findsWidgets);
      expect(find.descendant(of: find.byKey(const ValueKey('press')), matching: find.byType(NeuInset)), findsNothing);
    });
  });
}
