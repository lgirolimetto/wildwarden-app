import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/theme/livery.dart';
import 'package:flutter/material.dart';

/// Costruisce il `ThemeData` Material 3 di una livrea. I temi dei componenti derivano tutti dalla palette
/// e dai token: le pagine non devono mai usare colori letterali.
///
/// Con [dense] il tema delle pagine dense, se la livrea lo prevede (`DruidTokens.denseBackground` e `denseSurface`):
/// sfondo e superfici (schede, chip, pulsanti) più chiari. `null` se la livrea non lo prevede.
ThemeData buildTheme(Livery livery, Brightness brightness) => _buildTheme(livery, brightness, dense: false)!;

ThemeData? buildDenseTheme(Livery livery, Brightness brightness) => _buildTheme(livery, brightness, dense: true);

ThemeData? _buildTheme(Livery livery, Brightness brightness, {required bool dense}) {
  var scheme = livery.colorScheme(brightness);
  var tokens = livery.tokens(brightness, scheme);
  if (dense) {
    final background = tokens.denseBackground, surface = tokens.denseSurface;
    if (background == null || surface == null) return null;
    scheme = scheme.copyWith(surface: background, surfaceContainerLow: surface);
    tokens = tokens.copyWith(backgroundGradient: [background, background]);
  }
  final radius = BorderRadius.circular(tokens.cardRadius);

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: livery.fontFamily,
    scaffoldBackgroundColor: tokens.backgroundGradient.last,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.backgroundGradient.first,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    chipTheme: tokens.clay
        // Chip come piccole pillole sollevate, senza bordo.
        ? ChipThemeData(
            shape: const StadiumBorder(side: BorderSide.none),
            side: BorderSide.none,
            backgroundColor: scheme.surfaceContainerLow,
            selectedColor: scheme.primaryContainer,
            elevation: 3,
            pressElevation: 1,
            shadowColor: tokens.clayShadow,
            showCheckmark: false,
          )
        : ChipThemeData(
            shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
          ),
    segmentedButtonTheme: tokens.clay
        ? SegmentedButtonThemeData(
            style: ButtonStyle(
              side: WidgetStatePropertyAll(BorderSide(color: scheme.surfaceContainerHigh, width: 2)),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? scheme.primaryContainer : scheme.surfaceContainerLow,
              ),
              elevation: const WidgetStatePropertyAll(3),
              shadowColor: WidgetStatePropertyAll(tokens.clayShadow),
            ),
          )
        : null,
    // Campi di testo "scavati" nella plastilina: pieni, senza bordo, molto arrotondati.
    inputDecorationTheme: tokens.clay
        ? InputDecorationThemeData(
            filled: true,
            fillColor: scheme.onSurface.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
          )
        : null,
    bottomSheetTheme: tokens.clay
        ? BottomSheetThemeData(
            backgroundColor: scheme.surfaceContainerLow,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
            showDragHandle: true,
          )
        : null,
    dialogTheme: tokens.clay
        ? DialogThemeData(
            backgroundColor: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          )
        : null,
    dividerTheme: tokens.clay ? DividerThemeData(color: scheme.onSurface.withValues(alpha: 0.08)) : null,
    filledButtonTheme: FilledButtonThemeData(
      style: tokens.clay
          ? clayButtonStyle(
              color: scheme.primary,
              foreground: scheme.onPrimary,
              disabled: scheme.surfaceContainerHigh,
              concave: true,
            )
          : FilledButton.styleFrom(shape: const StadiumBorder()),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: tokens.clay
          ? clayButtonStyle(
              color: scheme.surfaceContainerLow,
              foreground: scheme.primary,
              disabled: scheme.surfaceContainerHigh,
            )
          : OutlinedButton.styleFrom(shape: const StadiumBorder()),
    ),
    elevatedButtonTheme: tokens.clay
        ? ElevatedButtonThemeData(
            style: clayButtonStyle(
              color: scheme.surfaceContainerLow,
              foreground: scheme.primary,
              disabled: scheme.surfaceContainerHigh,
            ),
          )
        : null,
    snackBarTheme: tokens.clay
        ? SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: radius),
          )
        : null,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
    ),
    extensions: [tokens],
  );

  final display = livery.displayFontFamily;
  if (display == null) return base;
  // Font della livrea solo per titoli e intestazioni: il testo corrente resta leggibile con il font di sistema.
  TextStyle? withDisplay(TextStyle? style) => style?.copyWith(fontFamily: display);
  final t = base.textTheme;
  return base.copyWith(
    textTheme: t.copyWith(
      displayLarge: withDisplay(t.displayLarge),
      displayMedium: withDisplay(t.displayMedium),
      displaySmall: withDisplay(t.displaySmall),
      headlineLarge: withDisplay(t.headlineLarge),
      headlineMedium: withDisplay(t.headlineMedium),
      headlineSmall: withDisplay(t.headlineSmall),
      titleLarge: withDisplay(t.titleLarge),
    ),
  );
}
