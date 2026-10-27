import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/livery.dart';
import 'package:druid_app/user_interface/theme/liveries/grade_colors.dart';
import 'package:druid_app/user_interface/theme/liveries/potion_colors.dart';
import 'package:flutter/material.dart';

/// Livrea alternativa: indaco e argento lunare. Esiste anche per dimostrare che il cambio di livrea
/// funziona senza toccare le pagine.
class NotturnaLivery extends Livery {
  const NotturnaLivery();

  @override
  String get id => 'notturna';

  @override
  String displayName(AppLocalizations l10n) => l10n.liveryNotturna;

  @override
  Color get seed => const Color(0xFF3D4C8C);

  @override
  DruidTokens tokens(Brightness brightness, ColorScheme scheme) {
    final light = brightness == Brightness.light;
    return DruidTokens(
      gradeColors: metalGradeColors(brightness),
      traitColors: potionTraitColors(brightness),
      plainPotion: plainPotionColor(brightness),
      speciesName: speciesNameColor(brightness),
      levelColors: light
          ? const [Color(0xFFC3C7D9), Color(0xFF9AA3CC), Color(0xFF6C7AB8), Color(0xFF3D4C8C), Color(0xFF9A8A4A)]
          : const [Color(0xFF3B4058), Color(0xFF55608F), Color(0xFF7C88C2), Color(0xFFA9B4EC), Color(0xFFD9CC8A)],
      hint: scheme.onSurfaceVariant,
      warning: light ? const Color(0xFF8A6410) : const Color(0xFFE6C26E),
      backgroundGradient: light
          ? const [Color(0xFFEEF0FA), Color(0xFFD9DDF2)]
          : const [Color(0xFF151A2E), Color(0xFF0B0E1A)],
      heroGradient: const [Color(0xFF2B3670), Color(0xFF5563A8)],
      onHero: const Color(0xFFF2F4FF),
      accentCards: [for (var i = 0; i < 3; i++) AccentCard(scheme.surfaceContainerLow, scheme.onSurface)],
      cardRadius: 20,
    );
  }
}
