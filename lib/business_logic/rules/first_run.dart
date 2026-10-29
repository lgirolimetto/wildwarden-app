import 'package:druid_app/business_logic/interfaces/i_preferences.dart';

/// Onboarding di primo avvio (capitolo 03, 2026-10-29): regole (EULA), permessi spiegati, "Sei pronto a giocare".
/// Si salva nelle preferenze, non negli eventi: resta anche dopo "Azzera i progressi".

/// Versione delle regole: cambiando il testo in modo sostanziale si alza, e si chiedono di nuovo.
const termsVersion = 1;

/// Versione delle regole accettata (con "Accetto").
const termsAcceptedKey = 'terms_accepted_version';

/// L'onboarding è arrivato alla fine almeno una volta.
const firstRunDoneKey = 'first_run_done';

int acceptedTermsVersion(IPreferences preferences) => int.tryParse(preferences.getString(termsAcceptedKey) ?? '') ?? 0;

/// All'avvio si apre l'onboarding: regole mai accettate (o di una versione vecchia) o onboarding interrotto.
bool needsFirstRun(IPreferences preferences) =>
    acceptedTermsVersion(preferences) < termsVersion || preferences.getString(firstRunDoneKey) == null;
