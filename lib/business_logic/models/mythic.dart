import 'package:druid_app/business_logic/models/enums/potion_effect.dart';
import 'package:druid_app/business_logic/models/localized_text.dart';
import 'package:druid_app/business_logic/models/recipe.dart';

/// Finestra di date in cui una Mitica si può preparare, da un mese-giorno a un altro (anche a cavallo dell'anno).
class DateWindow {
  final int fromMonth;
  final int fromDay;
  final int toMonth;
  final int toDay;

  const DateWindow({required this.fromMonth, required this.fromDay, required this.toMonth, required this.toDay});

  /// Da `{"from": "12-06", "to": "12-20"}`.
  factory DateWindow.fromJson(Map<String, dynamic> json) {
    final (fromMonth, fromDay) = _monthDay(json['from'] as String);
    final (toMonth, toDay) = _monthDay(json['to'] as String);
    return DateWindow(fromMonth: fromMonth, fromDay: fromDay, toMonth: toMonth, toDay: toDay);
  }

  bool contains(DateTime day) {
    final from = fromMonth * 100 + fromDay, to = toMonth * 100 + toDay, at = day.month * 100 + day.day;
    return from <= to ? at >= from && at <= to : at >= from || at <= to;
  }

  static (int, int) _monthDay(String text) {
    final parts = text.split('-');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }
}

/// Mitica: ricetta scritta a mano, della Zona e numerata dentro la Zona ("Tavola n. 1"), legata ai suoi luoghi, feste e
/// tradizioni. Il nome ha 3 pezzi, che si scoprono uno alla volta come i componenti mancanti.
class Mythic {
  /// Numero tra le Mitiche della Zona.
  final int number;

  /// Id stabile: lo salveranno gli eventi.
  final String id;
  final List<LocalizedText> nameParts;
  final LocalizedText story;
  final List<Ingredient> ingredients;
  final PotionEffect effect;

  /// Effetto raccontato (sempre di gioco).
  final LocalizedText effectText;

  /// `null` = si prepara tutto l'anno.
  final DateWindow? window;

  const Mythic({
    required this.number,
    required this.id,
    required this.nameParts,
    required this.story,
    required this.ingredients,
    required this.effect,
    required this.effectText,
    this.window,
  });

  factory Mythic.fromJson(Map<String, dynamic> json) => Mythic(
    number: json['number'] as int,
    id: json['id'] as String,
    nameParts: (json['nameParts'] as List).map((p) => LocalizedText.fromJson(p as Map<String, dynamic>)).toList(),
    story: LocalizedText.fromJson(json['story'] as Map<String, dynamic>),
    ingredients: (json['ingredients'] as List).map((i) => Ingredient.fromJson(i as Map<String, dynamic>)).toList(),
    effect: PotionEffect.values.byName(json['effect'] as String),
    effectText: LocalizedText.fromJson(json['effectText'] as Map<String, dynamic>),
    window: json['window'] == null ? null : DateWindow.fromJson(json['window'] as Map<String, dynamic>),
  );

  /// Il nome, con i pezzi uniti; gli ultimi [missing] pezzi, ancora da trovare, diventano "…" (come `missingPiece`
  /// nei nomi ad affissi).
  String name(String languageCode, {int missing = 0}) {
    final shown = nameParts.length - missing.clamp(0, nameParts.length);
    return [for (final (i, p) in nameParts.indexed) i < shown ? p.resolve(languageCode) : '…'].join(' ');
  }
}
