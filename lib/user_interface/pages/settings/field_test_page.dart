import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/services/dependencies.dart';
import 'package:druid_app/controllers/field_test/field_test_controller.dart';
import 'package:druid_app/controllers/field_test/field_test_record.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/common_widgets/dense_area.dart';
import 'package:druid_app/user_interface/common_widgets/druid_background.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Strumento di prova (step 0 del blocco 2): foto, Pl@ntNet e GPS su piante vere, una riga del CSV per prova.
class FieldTestPage extends StatefulWidget {
  const FieldTestPage({super.key});

  @override
  State<FieldTestPage> createState() => _FieldTestPageState();
}

class _FieldTestPageState extends State<FieldTestPage> {
  final _expected = TextEditingController();
  final _place = TextEditingController();
  bool _confirmClear = false;

  @override
  void dispose() {
    _expected.dispose();
    _place.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DenseArea(
    child: Scaffold(
      appBar: clayAppBar(context, title: context.l10n.debugFieldTest),
      extendBodyBehindAppBar: true,
      body: DruidBackground(
        belowAppBar: true,
        child: GetBuilder<FieldTestController>(
          init: FieldTestController(
            Get.find(),
            Get.find(),
            Get.find(),
            Get.find(),
            Get.find(),
            systemCamera: Get.find<IPhotoSource>(tag: systemCameraTag),
          ),
          builder: (controller) => ListView(
            padding: const EdgeInsets.all(Gaps.l),
            children: [
              Text(context.l10n.fieldTestIntro),
              if (Get.find<AppConfig>().plantNetApiKey.isEmpty) ...[
                const SizedBox(height: Gaps.s),
                Text(context.l10n.fieldTestNoKey, style: TextStyle(color: context.colors.error)),
              ],
              const SizedBox(height: Gaps.l),
              TextField(
                key: const ValueKey('field-test-expected'),
                controller: _expected,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldTestExpected,
                  hintText: context.l10n.fieldTestExpectedHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Gaps.s),
              TextField(
                key: const ValueKey('field-test-place'),
                controller: _place,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldTestPlace,
                  hintText: context.l10n.fieldTestPlaceHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              ListTile(
                key: const ValueKey('field-test-system-camera'),
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.fieldTestSystemCamera),
                trailing: ClaySwitch(value: controller.useSystemCamera, onChanged: controller.setSystemCamera),
                onTap: () => controller.setSystemCamera(!controller.useSystemCamera),
              ),
              const SizedBox(height: Gaps.s),
              FilledButton.icon(
                key: const ValueKey('field-test-run'),
                onPressed: controller.running
                    ? null
                    : () => controller.run(expected: _expected.text, place: _place.text),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(context.l10n.fieldTestRun),
              ),
              if (controller.running) ...[
                const SizedBox(height: Gaps.s),
                const LinearProgressIndicator(),
                const SizedBox(height: Gaps.xs),
                Text(switch (controller.phase) {
                  FieldTestPhase.photo || FieldTestPhase.idle => context.l10n.fieldTestPhasePhoto,
                  FieldTestPhase.identifying => context.l10n.fieldTestPhaseIdentifying,
                  FieldTestPhase.locating => context.l10n.fieldTestPhaseLocating,
                }),
              ],
              if (controller.last case final last?) ...[const SizedBox(height: Gaps.l), _LastTest(record: last)],
              const Divider(height: Gaps.xl * 2),
              Text(context.l10n.fieldTestRows(controller.rows), style: context.texts.titleMedium),
              if (controller.logPath case final path?) SelectableText(path, style: context.texts.bodySmall),
              const SizedBox(height: Gaps.s),
              Wrap(
                spacing: Gaps.chip,
                runSpacing: Gaps.chipRun,
                children: [
                  OutlinedButton(
                    key: const ValueKey('field-test-copy'),
                    onPressed: controller.rows == 0
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: await controller.csv()));
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(context.l10n.fieldTestCopied)));
                            }
                          },
                    child: Text(context.l10n.fieldTestCopy),
                  ),
                  TextButton(
                    key: const ValueKey('field-test-clear'),
                    style: TextButton.styleFrom(foregroundColor: context.colors.error),
                    onPressed: controller.rows == 0
                        ? null
                        : () async {
                            if (!_confirmClear) return setState(() => _confirmClear = true);
                            await controller.clearLog();
                            setState(() => _confirmClear = false);
                          },
                    child: Text(_confirmClear ? context.l10n.fieldTestClearConfirm : context.l10n.fieldTestClear),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// L'ultima prova: esito, candidati, tempi e GPS.
class _LastTest extends StatelessWidget {
  final FieldTestRecord record;

  const _LastTest({required this.record});

  @override
  Widget build(BuildContext context) {
    String seconds(Duration? d) => d == null ? '–' : (d.inMilliseconds / 1000).toStringAsFixed(1);
    String metres(double? m) => m == null ? '–' : m.toStringAsFixed(0);
    return ClayCard(
      key: const ValueKey('field-test-last'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.fieldTestOutcome(record.outcome), style: context.texts.titleMedium),
          for (final candidate in record.candidates.take(3))
            Text(
              '${(candidate.score * 100).toStringAsFixed(candidate.score < 0.01 ? 1 : 0)} % · ${candidate.scientificName}'
              '${candidate.commonNames.isEmpty ? '' : ' (${candidate.commonNames.first})'}',
            ),
          const SizedBox(height: Gaps.s),
          Text(
            context.l10n.fieldTestTimes(
              seconds(record.photoTime),
              record.identifyTime?.inMilliseconds.toString() ?? '–',
              record.photoKb?.toString() ?? '–',
            ),
          ),
          if (record.remainingRequests case final remaining?) Text(context.l10n.fieldTestRemaining('$remaining')),
          if (record.diagnostics case final d?)
            Text(
              context.l10n.fieldTestCamera(
                d.receivedPerSecond.toStringAsFixed(0),
                d.analyzedPerSecond.toStringAsFixed(1),
                d.analysisMs.toStringAsFixed(1),
                '${d.captureMs}',
                '${d.resizeMs}',
              ),
            ),
          const SizedBox(height: Gaps.s),
          if (record.locationOutcome != 'ok')
            Text(record.locationOutcome, style: TextStyle(color: context.colors.error))
          else ...[
            Text(
              context.l10n.fieldTestGps(
                seconds(record.firstFix),
                metres(record.accuracyWithin(const Duration(seconds: 5))),
                metres(record.accuracyWithin(const Duration(seconds: 10))),
                metres(record.accuracyWithin(const Duration(seconds: 20))),
              ),
            ),
            Text(
              context.l10n.fieldTestGpsAfterPhoto(
                record.fixesDuringPhoto,
                seconds(record.firstFixAfterPhoto),
                metres(record.accuracyAfterPhoto),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
