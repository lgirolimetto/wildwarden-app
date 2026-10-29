import 'package:druid_app/business_logic/interfaces/i_permissions.dart';
import 'package:druid_app/controllers/first_run/first_run_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/routes.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Onboarding di primo avvio (capitolo 03, 2026-10-29): le regole nel mondo vero, poi i permessi spiegati prima della
/// finestra di sistema, infine "Sei pronto a giocare". Una pagina alla volta, senza barra in basso.
class FirstRunPage extends StatelessWidget {
  const FirstRunPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DruidBackground(
      child: SafeArea(
        child: GetBuilder<FirstRunController>(
          init: FirstRunController(Get.find(), Get.find()),
          global: false,
          builder: (run) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Progress(step: run.step),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(run.step),
                    child: switch (run.step) {
                      FirstRunStep.terms => _Terms(run),
                      FirstRunStep.camera => _PermissionStep(
                        icon: Icons.photo_camera_outlined,
                        title: context.l10n.firstRunCameraTitle,
                        text: context.l10n.firstRunCameraText,
                        allowLabel: context.l10n.firstRunCameraAllow,
                        outcome: run.camera,
                        deniedText: context.l10n.firstRunCameraDenied,
                        busy: run.busy,
                        onAllow: run.requestCamera,
                        run: run,
                      ),
                      FirstRunStep.location => _PermissionStep(
                        icon: Icons.my_location_rounded,
                        title: context.l10n.firstRunLocationTitle,
                        text: context.l10n.firstRunLocationText,
                        allowLabel: context.l10n.firstRunLocationAllow,
                        outcome: run.location,
                        deniedText: run.location == PermissionOutcome.approximate
                            ? context.l10n.firstRunLocationApproximate
                            : context.l10n.firstRunLocationDenied,
                        busy: run.busy,
                        onAllow: run.requestLocation,
                        run: run,
                      ),
                      FirstRunStep.ready => _Ready(run),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// "Passo 2 di 4" e un pallino per pagina.
class _Progress extends StatelessWidget {
  final FirstRunStep step;

  const _Progress({required this.step});

  @override
  Widget build(BuildContext context) {
    final total = FirstRunStep.values.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.m, Gaps.l, Gaps.s),
      child: Semantics(
        label: context.l10n.firstRunProgress(step.index + 1, total),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final s in FirstRunStep.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.xs),
                child: ClayCircle(
                  size: 10,
                  color: s.index <= step.index ? context.colors.primary : context.colors.surfaceContainerHigh,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Le regole (bozza di EULA): una scheda con un'icona per regola, niente muro di testo; "Accetto" in fondo.
class _Terms extends StatelessWidget {
  final FirstRunController run;

  const _Terms(this.run);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rules = [
      (Icons.back_hand_outlined, l10n.firstRunRuleNoPickTitle, l10n.firstRunRuleNoPickText),
      (Icons.shield_outlined, l10n.firstRunRuleProtectedTitle, l10n.firstRunRuleProtectedText),
      (Icons.fence_outlined, l10n.firstRunRulePrivateTitle, l10n.firstRunRulePrivateText),
      (Icons.wb_twilight_rounded, l10n.firstRunRuleDaylightTitle, l10n.firstRunRuleDaylightText),
      (Icons.directions_walk_rounded, l10n.firstRunRuleSafetyTitle, l10n.firstRunRuleSafetyText),
      (Icons.warning_amber_rounded, l10n.firstRunRuleToxicTitle, l10n.firstRunRuleToxicText),
      (Icons.psychology_alt_outlined, l10n.firstRunRuleIdentifyTitle, l10n.firstRunRuleIdentifyText),
      (Icons.lock_outline_rounded, l10n.firstRunRulePrivacyTitle, l10n.firstRunRulePrivacyText),
    ];
    return ListView(
      key: const ValueKey('first-run-terms'),
      padding: const EdgeInsets.all(Gaps.l),
      children: [
        Text(l10n.firstRunWelcomeTitle, style: context.texts.headlineMedium),
        const SizedBox(height: Gaps.s),
        Text(l10n.firstRunWelcomeIntro, style: context.texts.bodyLarge),
        const SizedBox(height: Gaps.l),
        for (final (icon, title, text) in rules)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.m),
            child: ClayCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClayCircle(
                    size: 44,
                    color: context.colors.surfaceContainerHigh,
                    icon: icon,
                    iconColor: context.colors.primary,
                  ),
                  const SizedBox(width: Gaps.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.texts.titleMedium),
                        const SizedBox(height: Gaps.xs),
                        Text(text),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: Gaps.s),
        Text(l10n.firstRunTermsFooter, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
        const SizedBox(height: Gaps.l),
        Center(
          child: ClayButton(
            key: const ValueKey('first-run-accept'),
            label: l10n.firstRunAccept,
            icon: Icons.check_rounded,
            onPressed: run.acceptTerms,
          ),
        ),
        const SizedBox(height: Gaps.l),
      ],
    );
  }
}

/// Un permesso spiegato: perché serve, poi il pulsante che apre la finestra di sistema. Se il permesso manca dopo la
/// richiesta, che cosa non funzionerà, le impostazioni di Android e "Avanti".
class _PermissionStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final String allowLabel;
  final PermissionOutcome? outcome;
  final String deniedText;
  final bool busy;
  final Future<void> Function() onAllow;
  final FirstRunController run;

  const _PermissionStep({
    required this.icon,
    required this.title,
    required this.text,
    required this.allowLabel,
    required this.outcome,
    required this.deniedText,
    required this.busy,
    required this.onAllow,
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    final missing = outcome != null && outcome != PermissionOutcome.granted;
    return _Centered(
      icon: icon,
      title: title,
      text: text,
      children: [
        if (missing) ...[
          ClayCard(
            key: const ValueKey('first-run-denied'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: context.colors.tertiary),
                const SizedBox(width: Gaps.m),
                Expanded(child: Text(deniedText)),
              ],
            ),
          ),
          const SizedBox(height: Gaps.l),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Gaps.chip,
            runSpacing: Gaps.chipRun,
            children: [
              TextButton(
                key: const ValueKey('first-run-settings'),
                onPressed: run.openSettings,
                child: Text(context.l10n.firstRunOpenSettings),
              ),
              ClayButton(key: const ValueKey('first-run-next'), label: context.l10n.firstRunNext, onPressed: run.skip),
            ],
          ),
        ] else
          Center(
            child: busy
                ? const CircularProgressIndicator()
                : ClayButton(key: const ValueKey('first-run-allow'), label: allowLabel, icon: icon, onPressed: onAllow),
          ),
      ],
    );
  }
}

/// "Sei pronto a giocare": il tutorial o "Più tardi" (il tutorial resta in Home).
class _Ready extends StatelessWidget {
  final FirstRunController run;

  const _Ready(this.run);

  Future<void> _finish(BuildContext context) async {
    final navigator = Navigator.of(context);
    await run.finish();
    await navigator.pushNamedAndRemoveUntil<void>(Routes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) => _Centered(
    icon: Icons.eco_rounded,
    title: context.l10n.firstRunReadyTitle,
    text: context.l10n.firstRunReadyText,
    children: [
      Center(
        child: ClayButton(
          key: const ValueKey('first-run-tutorial'),
          label: context.l10n.firstRunStartTutorial,
          icon: Icons.school_outlined,
          onPressed: () => _finish(context),
        ),
      ),
      const SizedBox(height: Gaps.m),
      Center(
        child: TextButton(
          key: const ValueKey('first-run-later'),
          onPressed: () => _finish(context),
          child: Text(context.l10n.firstRunLater),
        ),
      ),
      Text(
        context.l10n.firstRunLaterNote,
        textAlign: TextAlign.center,
        style: context.texts.bodySmall?.copyWith(color: context.druid.hint),
      ),
    ],
  );
}

/// Un'icona grande, il titolo, il testo e sotto i pulsanti: le pagine dei permessi e quella finale.
class _Centered extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final List<Widget> children;

  const _Centered({required this.icon, required this.title, required this.text, required this.children});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(Gaps.xl),
    children: [
      const SizedBox(height: Gaps.xl),
      Center(
        child: ClayCircle(
          size: 96,
          color: context.colors.surfaceContainerHigh,
          icon: icon,
          iconColor: context.colors.primary,
        ),
      ),
      const SizedBox(height: Gaps.xl),
      Text(title, textAlign: TextAlign.center, style: context.texts.headlineMedium),
      const SizedBox(height: Gaps.m),
      Text(text, textAlign: TextAlign.center, style: context.texts.bodyLarge),
      const SizedBox(height: Gaps.xl),
      ...children,
    ],
  );
}
