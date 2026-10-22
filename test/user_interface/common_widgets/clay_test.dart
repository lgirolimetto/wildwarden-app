import 'package:druid_app/business_logic/models/enums/season.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/diorama.dart';
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

    test('emoji iniziale dei tratti', () {
      expect(leadingEmoji('🌕 Lunare'), '🌕');
      expect(leadingEmoji('❄️ Gelo'), '❄️');
      expect(leadingEmoji('Base'), isNull);
      expect(leadingEmoji(''), isNull);
    });
  });
}
