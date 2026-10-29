import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/species.dart';

/// La frase delle **Affinità** nella pagina della pianta (capitolo 02, 2026-10-29): solo testo, dai dati del catalogo
/// (luce e umidità EIVE, fasce di quota). Descrive la pianta, non le sue Qualia: può stonare con le Tavole (la Marruca
/// ama il secco ma ha la Nebbia), ed è voluto.

enum LightLiking { full, half, shade }

enum MoistureLiking { dry, damp }

/// Che cosa dice la frase: la luce, l'umidità solo se netta, le fasce di quota dove la pianta sta davvero.
typedef AffinityProfile = ({LightLiking? light, MoistureLiking? moisture, List<AltitudeBand> bands});

/// Quota minima di osservazioni in una fascia perché la frase la nomini.
const affinityBandShare = 0.25;

AffinityProfile affinityProfile(Species s) {
  final light = s.traits.light;
  final moisture = s.traits.moisture;
  return (
    light: light == null
        ? null
        : light >= 6.5
        ? LightLiking.full
        : light <= 4
        ? LightLiking.shade
        : LightLiking.half,
    moisture: moisture == null
        ? null
        : moisture <= 3.5
        ? MoistureLiking.dry
        : moisture >= 6
        ? MoistureLiking.damp
        : null,
    bands: [
      for (final b in AltitudeBand.values)
        if ((s.bandShare[b] ?? 0) >= affinityBandShare) b,
    ],
  );
}
