import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/livery.dart';
import 'package:flutter/material.dart';

/// Livrea materica e calda: verde petrolio, cacao, sabbia e crema, pulsanti pesca-dorato, sfondo con grana e
/// nervature di foglia, titoli in serif. Di giorno carta d'erbario color sabbia, di notte sottobosco.
class SottoboscoLivery extends Livery {
  const SottoboscoLivery();

  static const _forest = Color(0xFF2F5D4E);
  static const _cocoa = Color(0xFF6B4430);
  static const _sand = Color(0xFFD8BFA0);
  static const _peach = Color(0xFFE2B98F);
  static const _cream = Color(0xFFF5EBDD);
  static const _bark = Color(0xFF2B2118);

  @override
  String get id => 'sottobosco';

  @override
  String displayName(AppLocalizations l10n) => l10n.liverySottobosco;

  @override
  Color get seed => _forest;

  @override
  String? get displayFontFamily => 'YoungSerif';

  @override
  ColorScheme colorScheme(Brightness brightness) {
    final base = super.colorScheme(brightness);
    return brightness == Brightness.light
        ? base.copyWith(
            primary: _forest,
            onPrimary: _cream,
            primaryContainer: const Color(0xFFCFE0CF),
            onPrimaryContainer: const Color(0xFF13302A),
            secondary: _cocoa,
            onSecondary: _cream,
            secondaryContainer: const Color(0xFFE9D3BA),
            onSecondaryContainer: const Color(0xFF3A2414),
            tertiary: const Color(0xFFB07A45),
            surface: const Color(0xFFF1E6D4),
            onSurface: _bark,
            onSurfaceVariant: const Color(0xFF6A5A48),
            surfaceContainerLowest: const Color(0xFFFFFBF4),
            surfaceContainerLow: const Color(0xFFFBF5EA),
            surfaceContainer: const Color(0xFFE6D5BC),
            surfaceContainerHigh: const Color(0xFFDDC9AC),
            surfaceContainerHighest: const Color(0xFFD3BD9D),
            outline: const Color(0xFF9C8569),
            outlineVariant: const Color(0xFFE0CDB2),
          )
        : base.copyWith(
            primary: _peach,
            onPrimary: _bark,
            primaryContainer: const Color(0xFF3D6E57),
            onPrimaryContainer: _cream,
            secondary: const Color(0xFFC79473),
            onSecondary: _bark,
            secondaryContainer: const Color(0xFF4A3426),
            onSecondaryContainer: _cream,
            tertiary: _sand,
            surface: const Color(0xFF16241E),
            onSurface: _cream,
            onSurfaceVariant: const Color(0xFFC9BBA6),
            surfaceContainerLowest: const Color(0xFF0E1813),
            surfaceContainerLow: const Color(0xFF1F332B),
            surfaceContainer: const Color(0xFF1B2C25),
            surfaceContainerHigh: const Color(0xFF243B31),
            surfaceContainerHighest: const Color(0xFF2D473C),
            outline: const Color(0xFF7D8F84),
            outlineVariant: const Color(0xFF2E4439),
          );
  }

  @override
  DruidTokens tokens(Brightness brightness, ColorScheme scheme) {
    final light = brightness == Brightness.light;
    return DruidTokens(
      levelColors: const [
        Color(0xFFBFAE95),
        Color(0xFF9FB58A),
        Color(0xFF6E9A6A),
        Color(0xFF3F7A5E),
        Color(0xFFC9963E),
      ],
      // Nessun velo: sulle foto sfocate dava un viraggio grigiastro.
      mysteryVeil: Colors.transparent,
      mysteryBlur: 7,
      hint: scheme.onSurfaceVariant,
      warning: light ? const Color(0xFF8A5A10) : const Color(0xFFE6C26E),
      backgroundGradient: light
          ? const [Color(0xFFF4EADB), Color(0xFFE6D4BA)]
          : const [Color(0xFF1B2D25), Color(0xFF0F1A15)],
      grainOpacity: light ? 0.05 : 0.07,
      leafPattern: light ? const Color(0x142F5D4E) : const Color(0x14F5EBDD),
      heroGradient: light ? const [_forest, Color(0xFF4C7F63)] : const [Color(0xFF24493D), Color(0xFF3D6E57)],
      onHero: _cream,
      accentCards: const [AccentCard(_forest, _cream), AccentCard(_cocoa, _cream), AccentCard(_sand, _bark)],
      cardRadius: 26,
      clay: true,
      clayShadow: light ? const Color(0x405A4330) : const Color(0x80000000),
    );
  }
}
