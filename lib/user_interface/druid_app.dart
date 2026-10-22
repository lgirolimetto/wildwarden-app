import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:druid_app/l10n/app_localizations.dart';
import 'package:druid_app/user_interface/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Radice dell'app: tema dalla livrea scelta, lingue, rotte.
class DruidApp extends StatelessWidget {
  const DruidApp({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<ThemeController>(
    builder: (theme) => GetMaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: resolveLocale,
      initialRoute: Routes.home,
      getPages: appPages,
    ),
  );
}

/// Italiano per chi ha il telefono in italiano, inglese per tutti gli altri.
Locale resolveLocale(Locale? device, Iterable<Locale> supported) =>
    supported.firstWhere((l) => l.languageCode == device?.languageCode, orElse: () => const Locale('en'));
