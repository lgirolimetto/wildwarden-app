import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/livery.dart';
import 'package:flutter/material.dart';

/// Livrea di default: verdi di prato e di bosco. Di giorno salvia chiara, di notte sottobosco.
class ErbarioLivery extends Livery {
  const ErbarioLivery();

  @override
  String get id => 'erbario';

  @override
  String displayName(AppLocalizations l10n) => l10n.liveryErbario;

  @override
  Color get seed => const Color(0xFF3F7A35);

  @override
  ColorScheme colorScheme(Brightness brightness) {
    final base = super.colorScheme(brightness);
    return brightness == Brightness.light
        ? base.copyWith(
            surface: const Color(0xFFEAF3E4),
            surfaceContainerLowest: const Color(0xFFFFFFFF),
            surfaceContainerLow: const Color(0xFFF7FBF3),
            surfaceContainer: const Color(0xFFDDEDD3),
            surfaceContainerHigh: const Color(0xFFD2E6C6),
            surfaceContainerHighest: const Color(0xFFC6DFB8),
            secondaryContainer: const Color(0xFFC3E3AE),
            onSecondaryContainer: const Color(0xFF16340F),
            outlineVariant: const Color(0xFFC2D8B5),
          )
        : base.copyWith(
            surface: const Color(0xFF0F1A0E),
            surfaceContainerLowest: const Color(0xFF0A1309),
            surfaceContainerLow: const Color(0xFF172616),
            surfaceContainer: const Color(0xFF1C2E1A),
            surfaceContainerHigh: const Color(0xFF233822),
            surfaceContainerHighest: const Color(0xFF2B4429),
            secondaryContainer: const Color(0xFF2E4D27),
            onSecondaryContainer: const Color(0xFFCDEBB9),
            outlineVariant: const Color(0xFF2F462C),
          );
  }

  @override
  DruidTokens tokens(Brightness brightness, ColorScheme scheme) {
    final light = brightness == Brightness.light;
    return DruidTokens(
      levelColors: light
          ? const [Color(0xFFB4C9A8), Color(0xFF8DC07A), Color(0xFF5FA34B), Color(0xFF2F7A2A), Color(0xFFC08B1E)]
          : const [Color(0xFF4A5E45), Color(0xFF6E9E5F), Color(0xFF8FC67A), Color(0xFFB6E39F), Color(0xFFF0C766)],
      mysteryVeil: light ? const Color(0x40EAF3E4) : const Color(0x500F1A0E),
      mysteryBlur: 7,
      hint: scheme.onSurfaceVariant,
      warning: light ? const Color(0xFF8A6410) : const Color(0xFFE6C26E),
      backgroundGradient: light
          ? const [Color(0xFFF1F8EB), Color(0xFFDCEDD0)]
          : const [Color(0xFF132112), Color(0xFF0B140A)],
      heroGradient: light ? const [Color(0xFF2F6B2A), Color(0xFF5E9B3E)] : const [Color(0xFF1F4A1C), Color(0xFF3F7A2E)],
      onHero: const Color(0xFFF4FBEF),
      accentCards: [for (var i = 0; i < 3; i++) AccentCard(scheme.surfaceContainerLow, scheme.onSurface)],
      cardRadius: 16,
    );
  }
}
