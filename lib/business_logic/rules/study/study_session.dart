import 'dart:math';

import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/game_event.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/business_logic/rules/study/facts.dart';
import 'package:druid_app/business_logic/rules/study/questions.dart';
import 'package:druid_app/business_logic/rules/study/xp_rules.dart';

/// Esito di una risposta, con l'evento da salvare.
class AnswerOutcome {
  final Question question;
  final AnswerOption chosen;
  final bool correct;
  final AnswerGiven event;

  /// Il fatto tornerà più avanti nella sessione, in un'altra forma.
  final bool willReturn;

  const AnswerOutcome({
    required this.question,
    required this.chosen,
    required this.correct,
    required this.event,
    required this.willReturn,
  });

  int get xp => event.xp;
}

class _Pending {
  final Fact fact;
  final QuestionForm? avoid;

  const _Pending(this.fact, {this.avoid});
}

/// Una sessione di studio: un livello di una specie (apprendimento) o i ripassi del giorno.
///
/// In apprendimento un fatto sbagliato torna dopo due domande, in un'altra forma, finché non viene superato;
/// il livello è superato quando la coda è vuota. Nei ripassi ogni fatto si chiede una volta sola.
class StudySession {
  final AnswerMode mode;
  final Catalog _catalog;
  final Random _random;
  final List<_Pending> _queue;
  final Set<String> _wrongInSession = {};

  /// Specie e livello studiati (solo in apprendimento).
  final String? speciesSci;
  final int? level;
  final int totalFacts;
  int completedFacts = 0;
  Question? _current;

  StudySession._(this.mode, this._catalog, this._random, List<Fact> facts, {this.speciesSci, this.level})
    : _queue = (facts.toList()..shuffle(_random)).map(_Pending.new).toList(),
      totalFacts = facts.length;

  factory StudySession.learning({
    required String speciesSci,
    required int level,
    required Catalog catalog,
    required Random random,
  }) {
    final species = catalog.speciesBySci(speciesSci)!;
    return StudySession._(
      AnswerMode.learning,
      catalog,
      random,
      factsAtLevel(species, catalog, level),
      speciesSci: speciesSci,
      level: level,
    );
  }

  factory StudySession.review({required List<Fact> dueFacts, required Catalog catalog, required Random random}) =>
      StudySession._(AnswerMode.review, catalog, random, dueFacts);

  bool get isFinished => _queue.isEmpty;

  /// Domanda corrente; ogni chiamata restituisce la stessa finché non si risponde.
  Question get current {
    final pending = _queue.first;
    return _current ??= buildQuestion(pending.fact, _catalog, _random, avoid: pending.avoid);
  }

  AnswerOutcome answer(AnswerOption chosen, {required GameState state, required DateTime at}) {
    final question = current;
    final fact = question.fact;
    final correct = question.isCorrect(chosen);
    final xp = mode == AnswerMode.learning
        ? XpRules.learning(
            correct: correct,
            wrongEarlierInSession: _wrongInSession.contains(fact.id),
            mistakeRewardedBefore: state.progressOf(fact.id).mistakeRewarded,
          )
        : XpRules.review(correct: correct);

    _queue.removeAt(0);
    _current = null;
    final willReturn = mode == AnswerMode.learning && !correct;
    if (willReturn) {
      _wrongInSession.add(fact.id);
      _queue.insert(min(2, _queue.length), _Pending(fact, avoid: question.form));
    } else {
      completedFacts++;
    }

    return AnswerOutcome(
      question: question,
      chosen: chosen,
      correct: correct,
      willReturn: willReturn,
      event: AnswerGiven(factId: fact.id, correct: correct, mode: mode, xp: xp, occurredAt: at),
    );
  }
}
