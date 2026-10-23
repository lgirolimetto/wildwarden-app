import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Pagina densa (ricette, impostazioni, glossario…): se la livrea lo prevede, sfondo e superfici più chiari (es. Feltro
/// di sera: sfondo come il vassoio dell'erbario, schede e chip come le tessere delle piante). Altrimenti non cambia
/// niente. Con [paintBackground] dipinge anche lo sfondo, per le pagine che stanno sopra lo sfondo di un'altra (le
/// schede della Home).
class DenseArea extends StatelessWidget {
  final Widget child;
  final bool paintBackground;

  const DenseArea({super.key, required this.child, this.paintBackground = false});

  @override
  Widget build(BuildContext context) => GetBuilder<ThemeController>(
    builder: (controller) {
      final theme = controller.denseTheme(Theme.of(context).brightness);
      if (theme == null) return child;
      return Theme(
        data: theme,
        child: paintBackground ? ColoredBox(color: theme.colorScheme.surface, child: child) : child,
      );
    },
  );
}
