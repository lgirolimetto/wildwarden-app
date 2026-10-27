import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Scheda di un oggetto con un grado (comune, non comune, rara, mitica): ricette oggi, poi Tavole, pozioni e
/// Bottino. Le schede sono tutte uguali, del colore della livrea: il grado lo dice il [GradeDot] nel contenuto.
class GradeCard extends StatelessWidget {
  final Grade grade;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GradeCard({
    super.key,
    required this.grade,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  /// Di sera le schede con il grado sono un tono più chiare delle altre: si staccano dallo sfondo scuro e il colore del
  /// grado non sta sul verde più cupo.
  static Color surfaceOf(BuildContext context) {
    final base = context.colors.surfaceContainerLow;
    return Theme.of(context).brightness == Brightness.dark ? Color.lerp(base, Colors.white, 0.08)! : base;
  }

  @override
  Widget build(BuildContext context) =>
      ClayCard(color: surfaceOf(context), padding: padding, onTap: onTap, child: child);
}

/// Il grado in un cerchietto: un piccolo incavo, come il solco della scheda, con dentro il colore del grado. Il nome
/// del grado resta per i lettori di schermo e come suggerimento a pressione lunga; la legenda spiega i colori.
/// [filled] falso: l'incavo vuoto, una Tavola che manca (si vede appena il colore del grado sul bordo).
class GradeDot extends StatelessWidget {
  static const size = 22.0;
  static const _gem = 12.0;

  final Grade grade;

  /// Nome del grado, nella lingua dell'utente.
  final String label;

  final bool filled;

  const GradeDot({super.key, required this.grade, required this.label, this.filled = true});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      label: label,
      child: SizedBox.square(
        dimension: size,
        child: NeuInset(
          radius: BorderRadius.circular(size / 2),
          color: GradeCard.surfaceOf(context),
          depth: 2,
          child: Center(
            child: DecoratedBox(
              decoration: filled
                  ? BoxDecoration(color: context.druid.gradeColor(grade.index), shape: BoxShape.circle)
                  : BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.druid.gradeColor(grade.index).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
              child: const SizedBox.square(dimension: _gem),
            ),
          ),
        ),
      ),
    ),
  );
}
