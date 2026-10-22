import 'package:druid_app/l10n/app_localizations.dart';

/// Nome del livello di studio di una specie (0 = incontrata ma non ancora studiata).
String levelName(AppLocalizations l10n, int level) => switch (level) {
  <= 0 => l10n.levelToStudy,
  1 => l10n.levelRecognise,
  2 => l10n.levelKnow,
  3 => l10n.levelWhereWhen,
  _ => l10n.levelMastery,
};
