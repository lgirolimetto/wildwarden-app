import 'package:druid_app/business_logic/rules/did_you_know.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Il testo di un "Lo sapevi che…".
String didYouKnowText(BuildContext context, DidYouKnow tip) => switch (tip) {
  DidYouKnow.storm => context.l10n.dykStorm,
  DidYouKnow.daylight => context.l10n.dykDaylight,
  DidYouKnow.moon => context.l10n.dykMoon,
  DidYouKnow.noPicking => context.l10n.dykNoPicking,
  DidYouKnow.oneDrawPerDay => context.l10n.dykOneDrawPerDay,
  DidYouKnow.isolation => context.l10n.dykIsolation,
};

/// Un "Lo sapevi che…" come toast: compare e sparisce da solo, senza fermare il gioco.
void showDidYouKnow(BuildContext context, DidYouKnow tip) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      key: ValueKey('did-you-know-${tip.name}'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 7),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dykTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: Gaps.xs),
          Text(didYouKnowText(context, tip)),
        ],
      ),
    ),
  );
}
