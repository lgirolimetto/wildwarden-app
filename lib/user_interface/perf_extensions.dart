import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:druid_app/user_interface/pages/species/species_page.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Comandi per misurare le prestazioni dal Mac, attraverso il VM service (`tools/perf/` nel core): aprire una
/// scheda e far scorrere la pagina sempre allo stesso modo, così le varianti si confrontano alla pari. Li registra
/// solo il punto di ingresso di sviluppo; servono con una build `--profile` (issue #15).
void registerPerfExtensions() {
  // Riapre la scheda da zero (sopra la Home), così i pittori ripartono con il codice o gli interruttori nuovi.
  registerExtension('ext.druid.open', (method, params) async {
    Get.until((route) => route.isFirst);
    unawaited(Get.to<void>(() => SpeciesPage(speciesSci: params['sci']!), transition: Transition.noTransition));
    return ServiceExtensionResponse.result('{}');
  });
  registerExtension('ext.druid.scroll', (method, params) async {
    final position = mainScrollPosition();
    if (position == null) {
      return ServiceExtensionResponse.error(ServiceExtensionResponse.extensionError, 'nessuno scorrimento in pagina');
    }
    await scrollThrough(position, rounds: int.parse(params['rounds'] ?? '4'));
    return ServiceExtensionResponse.result(jsonEncode({'max': position.maxScrollExtent}));
  });
}

/// Lo scorrimento verticale più lungo della pagina in cima (le pagine sotto restano nell'albero ma non contano).
ScrollPosition? mainScrollPosition() {
  ScrollPosition? best;
  void visit(Element e) {
    if (e is StatefulElement && e.state is ScrollableState) {
      final position = (e.state as ScrollableState).position;
      final current = ModalRoute.of(e)?.isCurrent ?? true;
      if (current &&
          position.axis == Axis.vertical &&
          position.hasContentDimensions &&
          (best == null || position.maxScrollExtent > best!.maxScrollExtent)) {
        best = position;
      }
    }
    e.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  return best;
}

/// Fino in fondo e di nuovo in cima, a velocità costante, [rounds] volte.
Future<void> scrollThrough(
  ScrollPosition position, {
  int rounds = 4,
  Duration leg = const Duration(milliseconds: 2500),
}) async {
  for (var i = 0; i < rounds; i++) {
    await position.animateTo(position.maxScrollExtent, duration: leg, curve: Curves.linear);
    await position.animateTo(0, duration: leg, curve: Curves.linear);
  }
}
