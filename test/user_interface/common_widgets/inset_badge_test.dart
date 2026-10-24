import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/inset_badge.dart';
import 'package:druid_app/user_interface/theme/app_theme.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/liveries/feltro_livery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('timbro dell\'incontro: scritta senza incavo, nel colore di studio più leggibile ($brightness)', (
      tester,
    ) async {
      final theme = buildTheme(const FeltroLivery(), brightness);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(child: StampBadge(text: '3 feb', label: 'Incontrata il')),
          ),
        ),
      );

      expect(find.byType(NeuInset), findsNothing);
      // Feltro: di giorno il petrolio del livello 3, di sera l'azzurrino del livello 1.
      final tokens = theme.extension<DruidTokens>()!;
      final color = tester.widget<Text>(find.text('3 feb')).style!.color;
      expect(color, tokens.levelColor(brightness == Brightness.light ? 3 : 1));
    });
  }
}
