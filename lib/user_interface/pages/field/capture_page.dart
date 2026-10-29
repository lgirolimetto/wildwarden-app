import 'dart:async';
import 'dart:io';

import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/station.dart';
import 'package:druid_app/business_logic/rules/field/capture.dart';
import 'package:druid_app/controllers/catalog/catalog_controller.dart';
import 'package:druid_app/controllers/field/capture_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/common_widgets/species_name.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "Attingi" (step 3 del Campo): apre il mirino, chiede l'ipotesi, mostra cosa ha visto Pl@ntNet e com'è
/// andata (incontro, stazione, PE).
class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  final _guess = TextEditingController();
  late final CaptureController _capture;

  @override
  void initState() {
    super.initState();
    final catalog = Get.find<CatalogController>();
    _capture = CaptureController(
      Get.find(),
      Get.find(),
      Get.find(),
      () => catalog.uiData.fold((_) => null, (c) => c),
      Get.find<AppConfig>(),
      Get.find(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _capture.start();
      // Fotocamera chiusa senza scattare: si torna da dove si era venuti.
      if (_capture.phase == CapturePhase.cancelled && mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    unawaited(_capture.discardPhotos());
    _guess.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: clayAppBar(context, title: context.l10n.captureTitle),
    extendBodyBehindAppBar: true,
    body: DruidBackground(
      belowAppBar: true,
      child: GetBuilder<CaptureController>(
        init: _capture,
        global: false,
        builder: (capture) => ListView(
          padding: const EdgeInsets.all(Gaps.l),
          children: [
            ...switch (capture.phase) {
              CapturePhase.idle || CapturePhase.shooting || CapturePhase.cancelled => const [],
              CapturePhase.noKey => [_Message(context.l10n.captureNoKey)],
              CapturePhase.limitReached => [
                _Message(context.l10n.captureLimitText, title: context.l10n.captureLimitTitle),
              ],
              CapturePhase.guessing => _guessing(context, capture),
              CapturePhase.identifying || CapturePhase.saving => [
                const SizedBox(height: Gaps.xl),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: Gaps.l),
                Text(context.l10n.captureIdentifying, textAlign: TextAlign.center),
              ],
              CapturePhase.failed => [
                _Message(context.l10n.captureFailed(capture.error ?? '')),
                const SizedBox(height: Gaps.l),
                Center(
                  child: ClayButton(
                    key: const ValueKey('capture-retry'),
                    label: context.l10n.captureRetry,
                    icon: Icons.refresh_rounded,
                    onPressed: capture.identify,
                  ),
                ),
              ],
              CapturePhase.review => _review(context, capture),
              CapturePhase.done => _done(context, capture.result!),
            },
          ],
        ),
      ),
    ),
  );

  List<Widget> _guessing(BuildContext context, CaptureController capture) {
    final catalog = Get.find<CatalogController>().uiData.fold((_) => null, (c) => c);
    return [
      if (capture.photo?.path case final path?) _UserPhoto(path),
      const SizedBox(height: Gaps.l),
      Text(context.l10n.captureGuessTitle, style: context.texts.titleLarge),
      const SizedBox(height: Gaps.s),
      Autocomplete<String>(
        optionsBuilder: (value) => _suggestions(context, catalog, value.text),
        onSelected: (option) => _guess.text = option,
        fieldViewBuilder: (context, controller, focus, onSubmitted) {
          controller.addListener(() => _guess.text = controller.text);
          return TextField(
            key: const ValueKey('capture-guess'),
            controller: controller,
            focusNode: focus,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: context.l10n.captureGuessHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.psychology_alt_outlined),
            ),
          );
        },
      ),
      const SizedBox(height: Gaps.l),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: Gaps.chip,
        runSpacing: Gaps.chipRun,
        children: [
          ClayButton(
            key: const ValueKey('capture-guess-confirm'),
            label: context.l10n.captureGuessConfirm,
            onPressed: () {
              FocusScope.of(context).unfocus();
              capture.submitGuess(_guess.text);
            },
          ),
          TextButton(
            key: const ValueKey('capture-guess-skip'),
            onPressed: () {
              FocusScope.of(context).unfocus();
              capture.submitGuess(null);
            },
            child: Text(context.l10n.captureGuessSkip),
          ),
        ],
      ),
    ];
  }

  /// Suggerimenti dalle piante della mappa: nome comune o scientifico, da tre lettere.
  Iterable<String> _suggestions(BuildContext context, Catalog? catalog, String text) {
    final query = text.trim().toLowerCase();
    if (catalog == null || query.length < 3) return const [];
    return {
      for (final species in catalog.species)
        for (final name in [context.game.name(species), species.sci])
          if (name.toLowerCase().contains(query)) name,
    }.take(6);
  }

  List<Widget> _review(BuildContext context, CaptureController capture) {
    final review = capture.review!;
    if (review.empty) return [_Message(context.l10n.captureNone)];
    return [
      Text(
        review.needsChoice ? context.l10n.captureContested : context.l10n.captureProposed,
        style: context.texts.titleMedium,
      ),
      const SizedBox(height: Gaps.s),
      for (final (i, choice) in review.choices.indexed) ...[
        _ChoiceCard(
          key: ValueKey('capture-choice-$i'),
          choice: choice,
          selected: i == capture.selected,
          userPhoto: capture.photo?.path,
          onTap: () => capture.select(i),
        ),
        const SizedBox(height: Gaps.s),
      ],
      const SizedBox(height: Gaps.m),
      Center(
        child: ClayButton(
          key: const ValueKey('capture-confirm'),
          label: context.l10n.captureConfirm,
          icon: Icons.check_rounded,
          onPressed: capture.confirm,
        ),
      ),
    ];
  }

  List<Widget> _done(BuildContext context, CaptureResult result) {
    final choice = result.choice;
    final name = choice.species == null
        ? (choice.candidate.commonNames.firstOrNull ?? choice.candidate.scientificName)
        : context.game.name(choice.species!);
    return [
      if (_capture.photo?.path case final path?) _UserPhoto(path),
      const SizedBox(height: Gaps.l),
      Text(
        name,
        key: const ValueKey('capture-result-name'),
        style: speciesNameStyle(context, context.texts.headlineSmall),
      ),
      Text(choice.candidate.scientificName, style: context.texts.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
      const SizedBox(height: Gaps.m),
      if (choice.kind != StationKind.zone) ...[
        _KindBadge(choice.kind),
        const SizedBox(height: Gaps.s),
        Text(choice.kind == StationKind.guest ? context.l10n.captureGuestText : context.l10n.captureDiscoveryText),
        const SizedBox(height: Gaps.m),
      ],
      if (switch (result.guess) {
            GuessResult.exact => context.l10n.captureGuessExact,
            GuessResult.genus => context.l10n.captureGuessGenus(choice.candidate.scientificName.split(' ').first),
            GuessResult.wrong => context.l10n.captureGuessWrong(_capture.guess ?? ''),
            GuessResult.none => null,
          }
          case final line?)
        Text(line, key: const ValueKey('capture-guess-result'), style: context.texts.titleMedium),
      Text(switch (result.station) {
        StationOutcome.created => context.l10n.captureStationCreated,
        StationOutcome.existing => context.l10n.captureStationExisting,
        StationOutcome.noPosition => context.l10n.captureStationNoPosition,
        StationOutcome.limitReached => context.l10n.captureStationLimit,
      }, key: const ValueKey('capture-station')),
      if (result.firstPhoto) Text(context.l10n.captureFirstPhoto, key: const ValueKey('capture-first-photo')),
      if (result.xp > 0) ...[
        const SizedBox(height: Gaps.s),
        Text(
          context.l10n.captureXp(result.xp),
          key: const ValueKey('capture-xp'),
          style: context.texts.titleLarge?.copyWith(color: context.colors.primary),
        ),
      ],
      const SizedBox(height: Gaps.xl),
      Center(
        child: ClayButton(
          key: const ValueKey('capture-done'),
          label: context.l10n.captureDone,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    ];
  }
}

class _Message extends StatelessWidget {
  final String text;
  final String? title;

  const _Message(this.text, {this.title});

  @override
  Widget build(BuildContext context) => ClayCard(
    key: const ValueKey('capture-message'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[Text(title!, style: context.texts.titleMedium), const SizedBox(height: Gaps.s)],
        Text(text),
      ],
    ),
  );
}

/// La foto della pianta intera: quella che resta nella stazione.
class _UserPhoto extends StatelessWidget {
  final String path;

  const _UserPhoto(this.path);

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(context.druid.cardRadius),
    child: AspectRatio(
      aspectRatio: 4 / 3,
      child: Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
    ),
  );
}

/// Un candidato di Pl@ntNet: la foto del catalogo (o la tua, fuori dalla mappa), il nome, il punteggio, il tipo.
class _ChoiceCard extends StatelessWidget {
  final CaptureChoice choice;
  final bool selected;
  final String? userPhoto;
  final VoidCallback onTap;

  const _ChoiceCard({
    super.key,
    required this.choice,
    required this.selected,
    required this.userPhoto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final species = choice.species;
    final name = species == null
        ? (choice.candidate.commonNames.firstOrNull ?? choice.candidate.scientificName)
        : context.game.name(species);
    final image = species?.images.firstOrNull?.url;
    return ClayCard(
      onTap: onTap,
      color: selected ? context.colors.secondaryContainer : null,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Gaps.s),
              child: image != null
                  ? RemoteImage(image)
                  : userPhoto != null
                  ? Image.file(File(userPhoto!), fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox())
                  : const SizedBox(),
            ),
          ),
          const SizedBox(width: Gaps.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: speciesNameStyle(context, context.texts.titleMedium, green: false)),
                Text(
                  choice.candidate.scientificName,
                  style: context.texts.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
                if (choice.kind != StationKind.zone) ...[const SizedBox(height: Gaps.xs), _KindBadge(choice.kind)],
              ],
            ),
          ),
          Text('${(choice.candidate.score * 100).round()} %', style: context.texts.labelLarge),
          if (selected) ...[
            const SizedBox(width: Gaps.s),
            Icon(Icons.check_circle_rounded, color: context.colors.primary),
          ],
        ],
      ),
    );
  }
}

/// Il segno di una Scoperta o di un'Ospite.
class _KindBadge extends StatelessWidget {
  final StationKind kind;

  const _KindBadge(this.kind);

  @override
  Widget build(BuildContext context) {
    final (icon, label) = kind == StationKind.guest
        ? (Icons.yard_outlined, context.l10n.captureKindGuest)
        : (Icons.new_releases_outlined, context.l10n.captureKindDiscovery);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: context.colors.tertiary),
        const SizedBox(width: Gaps.xs),
        Text(label, style: context.texts.labelLarge?.copyWith(color: context.colors.tertiary)),
      ],
    );
  }
}
