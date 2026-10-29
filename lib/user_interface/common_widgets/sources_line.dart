import 'package:druid_app/business_logic/interfaces/i_link_opener.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "Fonte: POWO (Kew) · Tox Info Suisse": i nomi delle fonti, ognuno un link che si apre nel browser (capitolo 04,
/// "sempre con le fonti": anche per dare la buona abitudine di citare).
class SourcesLine extends StatelessWidget {
  final List<SourceRef> sources;

  const SourcesLine(this.sources, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.texts.labelSmall?.copyWith(color: context.druid.hint);
    final link = style?.copyWith(decoration: TextDecoration.underline, color: context.colors.primary);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(context.l10n.sourcesLabel, style: style),
        for (final (i, source) in sources.indexed) ...[
          if (i > 0) Text(' · ', style: style),
          InkWell(
            key: ValueKey('source-${source.url}'),
            onTap: () => Get.find<ILinkOpener>().open(source.url),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Gaps.xs),
              child: Text(source.name, style: link),
            ),
          ),
        ],
      ],
    );
  }
}
