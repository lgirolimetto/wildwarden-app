import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/station_state.dart';
import 'package:druid_app/business_logic/rules/field/suspension.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/controllers/stations/stations_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/game_data_builder.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:druid_app/user_interface/common_widgets/species_picture.dart';
import 'package:druid_app/user_interface/pages/species/species_page.dart';
import 'package:druid_app/user_interface/pages/stations/station_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Le tue Stazioni (capitolo 02): per ognuna lo stato e quando torna pronta, quanta Vis può dare, l'avviso se nelle
/// prossime ore è previsto un temporale. Solo sul telefono, mai coordinate né mappa.
class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  final _stations = StationsController(Get.find());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: clayAppBar(context, title: context.l10n.stationsTitle),
    extendBodyBehindAppBar: true,
    body: DruidBackground(
      belowAppBar: true,
      child: GameDataBuilder(
        builder: (context, catalog, state, progress) => GetBuilder<StationsController>(
          init: _stations,
          global: false,
          initState: (_) => _stations.load(state.stations),
          builder: (forecasts) {
            final now = progress.now;
            final sorted = sortedStations(state.stations, catalog, state, now);
            return ListView(
              padding: const EdgeInsets.all(Gaps.l),
              children: [
                if (sorted.isEmpty)
                  Text(context.l10n.stationsEmpty, key: const ValueKey('stations-empty'))
                else ...[
                  Text(
                    context.l10n.stationsSummary(
                      sorted.where((s) => stationStatus(s, catalog, state, now) == StationStatus.ready).length,
                      sorted.length,
                    ),
                    style: context.texts.bodyMedium?.copyWith(color: context.druid.hint),
                  ),
                  const SizedBox(height: Gaps.m),
                  for (final station in sorted)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gaps.m),
                      child: _StationCard(
                        station: station,
                        catalog: catalog,
                        state: state,
                        now: now,
                        suspended: forecasts.suspendedAt(station, now),
                        storm: forecasts.upcomingAt(station, now),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    ),
  );
}

/// Prima le pronte, poi quelle che tornano pronte prima.
List<Station> sortedStations(List<Station> stations, Catalog catalog, GameState state, DateTime now) =>
    [...stations]..sort((a, b) {
      final ra = readyAt(a, catalog, state, now), rb = readyAt(b, catalog, state, now);
      final ta = ra == null || !now.isBefore(ra) ? now : ra, tb = rb == null || !now.isBefore(rb) ? now : rb;
      return ta.compareTo(tb);
    });

class _StationCard extends StatelessWidget {
  final Station station;
  final Catalog catalog;
  final GameState state;
  final DateTime now;

  /// La raccolta è sospesa adesso; [storm]: è prevista una sospensione nelle prossime ore.
  final Suspension? suspended;
  final Suspension? storm;

  const _StationCard({
    required this.station,
    required this.catalog,
    required this.state,
    required this.now,
    required this.suspended,
    required this.storm,
  });

  @override
  Widget build(BuildContext context) {
    final species = catalog.speciesBySci(station.speciesSci);
    final status = stationStatus(station, catalog, state, now);
    return ClayCard(
      key: ValueKey('station-card-${station.id}'),
      onTap: species == null ? null : () => Get.to<void>(() => SpeciesPage(speciesSci: species.sci)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.square(
              dimension: 56,
              child: station.photo != null
                  ? OwnPhoto(station.photo!)
                  : species != null
                  ? SpeciesPicture(species)
                  : ColoredBox(color: context.colors.surfaceContainerHigh),
            ),
          ),
          const SizedBox(width: Gaps.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stationName(context, station, catalog),
                  style: speciesNameStyle(context, context.texts.titleMedium, green: false),
                ),
                const SizedBox(height: Gaps.xs),
                Text(
                  stationStatusText(
                    context,
                    status: status,
                    readyAt: readyAt(station, catalog, state, now),
                    suspension: suspended,
                    now: now,
                  ),
                  key: ValueKey('station-status-${station.id}'),
                ),
                Text(
                  context.l10n.stationExpectedVis(visOfDraw(ring: 1, station: station, state: state)),
                  style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
                ),
                if (storm case final s?) ...[
                  const SizedBox(height: Gaps.xs),
                  Row(
                    children: [
                      Icon(Icons.thunderstorm_outlined, size: 18, color: context.druid.warning),
                      const SizedBox(width: Gaps.xs),
                      Expanded(
                        child: Text(
                          context.l10n.stationStormSoon(
                            suspensionReason(context, s.reason),
                            whenText(context, s.until, now),
                          ),
                          key: ValueKey('station-storm-${station.id}'),
                          style: TextStyle(color: context.druid.warning),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
