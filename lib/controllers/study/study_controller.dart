import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/progression.dart';
import 'package:druid_app/business_logic/rules/recipes/collection.dart';
import 'package:druid_app/business_logic/rules/recipes/recipe_book.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/business_logic/rules/study/study_session.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:get/get.dart';

/// Riepilogo di fine sessione.
class SessionSummary {
  final AnswerMode mode;
  final int answers;
  final int correct;
  final int xp;
  final String? speciesSci;
  final int? levelPassed;
  final bool masteryReached;

  /// La Comune della pianta, imparata superando il livello 1 (se non la conoscevi già).
  final PlantRecipe? learnedRecipe;

  const SessionSummary({
    required this.mode,
    required this.answers,
    required this.correct,
    required this.xp,
    this.speciesSci,
    this.levelPassed,
    this.masteryReached = false,
    this.learnedRecipe,
  });
}

/// Guida una sessione di studio: domanda, risposta, esito, domanda successiva, riepilogo.
class StudyController extends GetxController {
  final ProgressController _progress;
  final Random _random;

  StudyController(this._progress, {Random? random}) : _random = random ?? Random();

  StudySession? _session;
  Catalog? _catalog;

  /// Esito dell'ultima risposta, mostrato finché non si passa alla domanda successiva.
  AnswerOutcome? lastOutcome;
  SessionSummary? summary;
  int _answers = 0, _correct = 0, _xp = 0;

  bool get isActive => _session != null && summary == null;

  Question? get question => _session == null || _session!.isFinished ? null : _session!.current;

  int get completedFacts => _session?.completedFacts ?? 0;

  int get totalFacts => _session?.totalFacts ?? 0;

  AnswerMode? get mode => _session?.mode;

  String? get speciesSci => _session?.speciesSci;

  int? get level => _session?.level;

  void startLevel(Catalog catalog, String speciesSci, int level) =>
      _start(catalog, StudySession.learning(speciesSci: speciesSci, level: level, catalog: catalog, random: _random));

  /// Ripassi del giorno (al massimo 15 fatti per sessione). Restituisce `false` se non c'è niente da ripassare.
  bool startReview(Catalog catalog) {
    final due = dueFacts(catalog, _progress.state, _progress.now)..shuffle(_random);
    if (due.isEmpty) return false;
    _start(catalog, StudySession.review(dueFacts: due.take(15).toList(), catalog: catalog, random: _random));
    return true;
  }

  void _start(Catalog catalog, StudySession session) {
    _catalog = catalog;
    _session = session;
    lastOutcome = null;
    summary = null;
    _answers = _correct = _xp = 0;
    update();
  }

  Future<void> answer(AnswerOption chosen) async {
    final session = _session;
    if (session == null || session.isFinished || lastOutcome != null) return;
    final outcome = session.answer(chosen, state: _progress.state, at: _progress.now);
    lastOutcome = outcome;
    _answers++;
    if (outcome.correct) _correct++;
    _xp += outcome.xp;
    update();
    await _progress.record(outcome.event);
  }

  /// Passa alla domanda successiva, o chiude la sessione se era l'ultima.
  Future<void> next() async {
    final session = _session;
    if (session == null) return;
    lastOutcome = null;
    if (session.isFinished) {
      await _finish(session);
    }
    update();
  }

  Future<void> _finish(StudySession session) async {
    int? passed;
    PlantRecipe? learned;
    var mastery = false;
    if (session.mode == AnswerMode.learning) {
      passed = session.level;
      await _progress.record(
        LevelPassed(
          speciesSci: session.speciesSci!,
          level: passed!,
          xp: XpRules.levelPassed,
          occurredAt: _progress.now,
        ),
      );
      _xp += XpRules.levelPassed;
      await _skipEmptyLevels(session.speciesSci!);
      if (passed == recipeLearningLevel) {
        learned = commonToLearn(session.speciesSci!, _catalog!, _progress.state);
        if (learned != null) {
          await _progress.record(
            RecipeLearned(recipeId: learned.id, origin: RecipeOrigin.study, occurredAt: _progress.now),
          );
        }
      }
    }
    final touched = session.mode == AnswerMode.learning
        ? {session.speciesSci!}
        : {for (final id in _progress.state.facts.keys) Fact.parseId(id).speciesSci};
    for (final sci in touched) {
      final before = _progress.state.mastered.contains(sci);
      await _progress.checkMastery(sci);
      if (!before && _progress.state.mastered.contains(sci)) {
        mastery = true;
        _xp += XpRules.mastery;
      }
    }
    summary = SessionSummary(
      mode: session.mode,
      answers: _answers,
      correct: _correct,
      xp: _xp,
      speciesSci: session.speciesSci,
      levelPassed: passed,
      masteryReached: mastery,
      learnedRecipe: learned,
    );
  }

  /// Un livello senza fatti (dati insufficienti per farne domande) si considera superato, senza PE:
  /// altrimenti la specie non potrebbe mai arrivare alla maestria.
  Future<void> _skipEmptyLevels(String speciesSci) async {
    final catalog = _catalog!;
    final species = catalog.speciesBySci(speciesSci)!;
    for (var level = _progress.state.levelOf(speciesSci) + 1; level <= maxStudyLevel; level++) {
      if (factsAtLevel(species, catalog, level).isNotEmpty) return;
      await _progress.record(LevelPassed(speciesSci: speciesSci, level: level, xp: 0, occurredAt: _progress.now));
    }
  }

  void close() {
    _session = null;
    lastOutcome = null;
    summary = null;
    update();
  }
}
