import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/livery.dart';
import 'package:flutter/material.dart';

/// Livrea neumorfica: pagina sabbia con grana di feltro, pannelli dello stesso colore sollevati da luce e ombra,
/// azioni in terracotta e pesca, accenti crema; di sera verde ardesia. Le azioni restano colorate: nel neumorfismo
/// puro non si capirebbe cosa si può toccare.
///
/// La pagina è di tono medio: su un colore quasi bianco la luce non si vedrebbe e resterebbe solo l'ombra.
/// (Provata anche una pagina salvia-grigio, come il riferimento: scelta la sabbia.)
class FeltroLivery extends Livery {
  const FeltroLivery();

  static const _page = Color(0xFFE2D5C1);
  static const _sageDark = Color(0xFF2B3431);
  static const _terracotta = Color(0xFFC2764A);
  static const _peach = Color(0xFFEBC3A0);
  static const _cream = Color(0xFFF7F0E6);
  static const _teal = Color(0xFF4F6B66);
  static const _ink = Color(0xFF2F3B38);

  @override
  String get id => 'feltro';

  @override
  String displayName(AppLocalizations l10n) => l10n.liveryFeltro;

  @override
  Color get seed => _teal;

  @override
  ColorScheme colorScheme(Brightness brightness) {
    final base = super.colorScheme(brightness);
    return brightness == Brightness.light
        ? base.copyWith(
            primary: _terracotta,
            onPrimary: _cream,
            primaryContainer: _peach,
            onPrimaryContainer: const Color(0xFF4A2A17),
            secondary: _teal,
            onSecondary: _cream,
            secondaryContainer: const Color(0xFFD6C8B2),
            onSecondaryContainer: _ink,
            tertiary: _terracotta,
            surface: _page,
            onSurface: _ink,
            onSurfaceVariant: const Color(0xFF5D6B67),
            // Tessere dell'erbario: specie incontrate (Lowest) e da trovare (Bright).
            surfaceContainerLowest: const Color(0xFFFFFCF7),
            surfaceBright: _cream,
            surfaceContainerLow: _page,
            surfaceContainer: const Color(0xFFD9CBB5),
            surfaceContainerHigh: const Color(0xFFD2C3AC),
            surfaceContainerHighest: const Color(0xFFC9B9A1),
            outline: const Color(0xFF9C8B74),
            outlineVariant: const Color(0xFFD0C1AA),
          )
        : base.copyWith(
            primary: const Color(0xFFE7A97A),
            onPrimary: const Color(0xFF2B1A10),
            primaryContainer: const Color(0xFF6A4632),
            onPrimaryContainer: _cream,
            secondary: const Color(0xFF9DB8B1),
            onSecondary: const Color(0xFF16201D),
            secondaryContainer: const Color(0xFF3A4743),
            onSecondaryContainer: _cream,
            tertiary: const Color(0xFFE7A97A),
            surface: _sageDark,
            onSurface: const Color(0xFFE6E0D6),
            onSurfaceVariant: const Color(0xFFB4BDB9),
            surfaceContainerLowest: const Color(0xFF34403C),
            surfaceBright: _sageDark,
            surfaceContainerLow: _sageDark,
            surfaceContainer: const Color(0xFF313B37),
            surfaceContainerHigh: const Color(0xFF37423E),
            surfaceContainerHighest: const Color(0xFF3F4B47),
            outline: const Color(0xFF7D8A86),
            outlineVariant: const Color(0xFF3A4643),
          );
  }

  @override
  DruidTokens tokens(Brightness brightness, ColorScheme scheme) {
    final light = brightness == Brightness.light;
    return DruidTokens(
      levelColors: const [Color(0xFFBFCAC5), Color(0xFFA9C2B6), Color(0xFF7FA597), Color(0xFF4F6B66), _terracotta],
      hint: scheme.onSurfaceVariant,
      warning: light ? const Color(0xFF8A4A1A) : const Color(0xFFE6C26E),
      // Pagina e pannelli dello stesso colore: il rilievo lo fanno solo luce e ombra.
      backgroundGradient: light ? const [_page, _page] : const [_sageDark, _sageDark],
      grainOpacity: light ? 0.06 : 0.08,
      heroGradient: light ? const [_teal, Color(0xFF66837D)] : const [Color(0xFF3E5651), Color(0xFF4F6B66)],
      onHero: _cream,
      accentCards: light
          ? const [AccentCard(_page, _ink), AccentCard(_peach, Color(0xFF4A2A17)), AccentCard(_cream, _ink)]
          : const [
              AccentCard(_sageDark, Color(0xFFE6E0D6)),
              AccentCard(Color(0xFF5A3F2F), _cream),
              AccentCard(Color(0xFF34403C), Color(0xFFE6E0D6)),
            ],
      cardRadius: 22,
      clay: true,
      neu: true,
      neuLight: light ? const Color(0xE6FBF6EE) : const Color(0x14FFFFFF),
      clayShadow: light ? const Color(0xB3B3A086) : const Color(0xB3121816),
    );
  }
}
