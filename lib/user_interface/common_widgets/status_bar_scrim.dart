import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:flutter/material.dart';

/// Velo sotto la barra di stato: il contenuto che scorre sfuma nel colore dello sfondo invece di finire sotto
/// l'orologio. Con [opacity] < 1 si mostra solo in parte (es. nella Home, dove in cima c'è il cielo del diorama).
class StatusBarScrim extends StatelessWidget {
  final Color color;
  final double opacity;

  const StatusBarScrim({super.key, required this.color, this.opacity = 1});

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    right: 0,
    top: 0,
    height: MediaQuery.paddingOf(context).top + Gaps.l,
    child: IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.85), color.withValues(alpha: 0)],
              stops: const [0, 0.6, 1],
            ),
          ),
        ),
      ),
    ),
  );
}
