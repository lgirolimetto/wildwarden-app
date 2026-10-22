import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Scheda decorativa con i colori `accentCards` della livrea, scelti a rotazione con [index].
/// Testi e icone all'interno prendono il colore della scheda. Il contenuto si costruisce con [builder], che riceve
/// un `context` sotto il tema della scheda: gli stili letti da lì (`context.texts`…) hanno già il colore giusto.
class AccentCardBox extends StatelessWidget {
  final int index;
  final WidgetBuilder builder;

  const AccentCardBox({super.key, required this.index, required this.builder});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    final accent = tokens.accent(index);
    final theme = Theme.of(context);
    final fg = accent.foreground;
    final decoration = tokens.clay
        ? clayDecoration(context, color: accent.background)
        : BoxDecoration(
            color: accent.background,
            borderRadius: BorderRadius.circular(tokens.cardRadius),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          );
    return DecoratedBox(
      decoration: decoration,
      child: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.apply(bodyColor: fg, displayColor: fg),
          iconTheme: theme.iconTheme.copyWith(color: fg),
          colorScheme: theme.colorScheme.copyWith(onSurface: fg, onSurfaceVariant: fg.withValues(alpha: 0.8)),
          // Anche gli indizi seguono il colore della scheda, altrimenti su fondi scuri non si leggono.
          extensions: [tokens.copyWith(hint: fg.withValues(alpha: 0.75))],
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: fg),
          child: Builder(builder: builder),
        ),
      ),
    );
  }
}
