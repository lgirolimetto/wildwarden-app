import 'dart:math' as math;

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/grade.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/grade_card.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/pages/recipe_book/recipe_page.dart';
import 'package:druid_app/user_interface/pages/recipe_book/widgets/plate_face.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// L'apertura di un Bottino dell'Esperienza: le Tavole uscite arrivano coperte e si girano toccandole. Quel che è
/// uscito è già salvato: la pagina lo mostra soltanto.
class TroveOpeningPage extends StatelessWidget {
  final Grade grade;
  final List<TroveFind> finds;

  const TroveOpeningPage({super.key, required this.grade, required this.finds});

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.troveName(context.game.troveGrade(grade))),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GameDataBuilder(
          builder: (context, catalog, state, _) => ListView(
            key: const ValueKey('trove-opening'),
            padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.s, Gaps.l, Gaps.xl),
            children: [
              Text(
                finds.isEmpty ? context.l10n.troveNothing : context.l10n.troveTapToTurn,
                style: context.texts.bodyMedium?.copyWith(color: context.druid.hint),
              ),
              const SizedBox(height: Gaps.l),
              for (final (i, find) in finds.indexed) ...[
                _FlipPlate(
                  key: ValueKey('trove-find-$i'),
                  find: find,
                  front: _FindFront(find: find, catalog: catalog, state: state),
                ),
                const SizedBox(height: Gaps.l),
              ],
              Center(
                child: ClayButton(
                  key: const ValueKey('trove-done'),
                  label: context.l10n.troveDone,
                  onPressed: () => Get.back<void>(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Una Tavola coperta che si gira con un tocco; girata, un tocco apre la ricetta.
class _FlipPlate extends StatefulWidget {
  final TroveFind find;
  final Widget front;

  const _FlipPlate({super.key, required this.find, required this.front});

  @override
  State<_FlipPlate> createState() => _FlipPlateState();
}

class _FlipPlateState extends State<_FlipPlate> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tap() {
    if (_controller.value == 0) {
      _controller.forward();
      return;
    }
    final id = widget.find.recipeId;
    Get.to<void>(
      () => widget.find.grade == Grade.mythic ? MythicRecipePage(mythicId: id) : PlantRecipePage(recipeId: id),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _tap,
    child: SizedBox(
      height: 260,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          final showFront = t >= 0.5;
          // Mezzo giro: la faccia coperta fino a metà, poi quella scoperta (girata a sua volta per non essere a
          // specchio).
          final angle = t * math.pi + (showFront ? math.pi : 0);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: GradeCard(
              grade: widget.find.grade,
              child: showFront ? widget.front : _Back(grade: widget.find.grade),
            ),
          );
        },
      ),
    ),
  );
}

/// Il dorso della Tavola: solo il grado.
class _Back extends StatelessWidget {
  final Grade grade;

  const _Back({required this.grade});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GradeDot(grade: grade, label: context.game.grade(grade)),
      const Expanded(child: Center(child: EngravedIcon(Icons.auto_awesome_rounded, size: 56))),
      Text(context.game.grade(grade), style: TextStyle(color: context.druid.hint)),
    ],
  );
}

/// La faccia della Tavola uscita: la Tavola com'è adesso, con che cosa è uscito.
class _FindFront extends StatelessWidget {
  final TroveFind find;
  final Catalog catalog;
  final GameState state;

  const _FindFront({required this.find, required this.catalog, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final missing = state.missingPieces[find.recipeId] ?? 0;
    final caption = switch (find.kind) {
      // Quanti Componenti mancano lo dice la Tavola aperta: qui bastano le rune del nome (2026-10-29).
      TroveFindKind.recipe when find.taste => l10n.troveFindTaste,
      TroveFindKind.recipe => l10n.troveFindNew,
      TroveFindKind.piece => missing == 0 ? l10n.troveFindCompleted : l10n.troveFindPiece,
      TroveFindKind.recycled => l10n.troveFindRecycled(context.game.troveGrade(find.grade)),
    };
    if (find.grade == Grade.mythic) {
      final mythic = catalog.mythics.firstWhere((m) => m.id == find.recipeId);
      return MythicFace(mythic: mythic, missing: missing, caption: caption);
    }
    final recipe = recipeBookOf(catalog).recipeById(find.recipeId)!;
    return PlateFace(recipe: recipe, missing: missing, caption: caption);
  }
}
