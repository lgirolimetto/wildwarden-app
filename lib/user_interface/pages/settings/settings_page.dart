import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/services/clock/offset_clock.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/controllers/subscription/subscription_controller.dart';
import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:druid_app/user_interface/pages/glossary/glossary.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/livery_registry.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<ThemeController>(
    builder: (controller) => ListView(
      padding: EdgeInsets.fromLTRB(Gaps.l, MediaQuery.paddingOf(context).top + Gaps.l, Gaps.l, homeBottomInset),
      children: [
        ClayPageHeader(
          title: context.l10n.settingsTitle,
          icon: Icons.tune_rounded,
          iconColor: context.colors.secondaryContainer,
        ),
        const SizedBox(height: Gaps.xl),
        Text(context.l10n.liveryLabel, style: context.texts.titleMedium),
        const SizedBox(height: Gaps.s),
        Wrap(
          spacing: Gaps.chip,
          runSpacing: Gaps.chipRun,
          children: [
            for (final livery in LiveryRegistry.all)
              ClayChip(
                key: ValueKey('livery-${livery.id}'),
                label: livery.displayName(context.l10n),
                avatar: ClayCircle(color: livery.seed, size: 22),
                selected: controller.livery.id == livery.id,
                onTap: () => controller.selectLivery(livery),
              ),
          ],
        ),
        const SizedBox(height: Gaps.xl),
        Text(context.l10n.themeModeLabel, style: context.texts.titleMedium),
        const SizedBox(height: Gaps.s),
        // Pillole come per le livree, con una sfera-icona: più giocoso del selettore segmentato.
        Wrap(
          spacing: Gaps.chip,
          runSpacing: Gaps.chipRun,
          children: [
            for (final (mode, label, icon) in [
              (ThemeMode.system, context.l10n.themeModeSystem, Icons.brightness_auto_rounded),
              (ThemeMode.light, context.l10n.themeModeLight, Icons.wb_sunny_rounded),
              (ThemeMode.dark, context.l10n.themeModeDark, Icons.nightlight_round),
            ])
              ClayChip(
                key: ValueKey('mode-${mode.name}'),
                label: label,
                avatar: Icon(icon, size: 18),
                selected: controller.mode == mode,
                onTap: () => controller.selectMode(mode),
              ),
          ],
        ),
        const SizedBox(height: Gaps.xl),
        ClayCard(
          padding: const EdgeInsets.symmetric(vertical: Gaps.xs),
          onTap: () => Get.to<void>(() => const GlossaryPage()),
          child: ListTile(
            leading: const ClayInsetIcon(icon: Icons.menu_book_rounded),
            title: Text(context.l10n.glossaryTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
        if (Get.find<AppConfig>().showDebugTools) ...[const Divider(height: Gaps.xl * 2), const _DebugTools()],
      ],
    ),
  );
}

/// Strumenti per provare l'app sul simulatore: tempo, abbonamento simulato, azzeramento. Solo in sviluppo.
class _DebugTools extends StatefulWidget {
  const _DebugTools();

  @override
  State<_DebugTools> createState() => _DebugToolsState();
}

class _DebugToolsState extends State<_DebugTools> {
  bool _confirmReset = false;

  @override
  Widget build(BuildContext context) {
    final clock = Get.isRegistered<OffsetClock>() ? Get.find<OffsetClock>() : null;
    final progress = Get.find<ProgressController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.debugTitle, style: context.texts.titleMedium),
        const SizedBox(height: Gaps.s),
        if (clock != null) ...[
          Text(context.l10n.debugDays(clock.offsetDays)),
          const SizedBox(height: Gaps.xs),
          Wrap(
            spacing: Gaps.chip,
            runSpacing: Gaps.chipRun,
            children: [
              for (final days in [1, 3, 7])
                OutlinedButton(
                  key: ValueKey('advance-$days'),
                  onPressed: () async {
                    await clock.advanceDays(days);
                    await progress.revealTodayFunFact();
                    progress.update();
                    setState(() {});
                  },
                  child: Text(context.l10n.debugAdvance(days)),
                ),
            ],
          ),
        ],
        GetBuilder<SubscriptionController>(
          builder: (subscription) => ListTile(
            key: const ValueKey('debug-diario'),
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.debugDiario),
            trailing: ClaySwitch(value: subscription.diarioActive, onChanged: subscription.setSimulated),
            onTap: () => subscription.setSimulated(!subscription.diarioActive),
          ),
        ),
        TextButton.icon(
          key: const ValueKey('debug-reset'),
          style: TextButton.styleFrom(foregroundColor: context.colors.error),
          onPressed: () async {
            if (!_confirmReset) return setState(() => _confirmReset = true);
            await progress.resetAll();
            await clock?.reset();
            setState(() => _confirmReset = false);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.debugResetDone)));
            }
          },
          icon: const Icon(Icons.delete_outline),
          label: Text(_confirmReset ? context.l10n.debugResetConfirm : context.l10n.debugReset),
        ),
      ],
    );
  }
}
