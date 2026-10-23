import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/models/enums/altitude_band.dart';
import 'package:druid_app/business_logic/models/species_traits.dart';
import 'package:druid_app/business_logic/rules/erbario_views.dart';
import 'package:druid_app/controllers/erbario/erbario_views_controller.dart';
import 'package:druid_app/user_interface/common_widgets/clay.dart';
import 'package:druid_app/user_interface/game_texts.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Le viste dell'erbario in una fila di chip: quelle già pronte, quelle salvate (pressione lunga per eliminarle) e
/// "Nuova vista".
class ErbarioViewsBar extends StatelessWidget {
  final Catalog catalog;

  const ErbarioViewsBar({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) => GetBuilder<ErbarioViewsController>(
    builder: (views) => SizedBox(
      // Più spazio in verticale che in orizzontale: le ombre del rilievo non si tagliano.
      height: 48 + 2 * Gaps.m,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: Gaps.l, vertical: Gaps.m),
        children: [
          for (final view in BuiltInView.values)
            _ViewChip(
              key: ValueKey('view-${view.name}'),
              label: context.game.builtInView(view),
              selected: views.selected == ErbarioViewsController.builtInKey(view),
              onTap: () => views.select(ErbarioViewsController.builtInKey(view)),
            ),
          for (final view in views.saved)
            _ViewChip(
              key: ValueKey('view-${view.id}'),
              label: view.name,
              selected: views.selected == view.id,
              onTap: () => views.select(view.id),
              onLongPress: () => _confirmRemove(context, views, view),
            ),
          _ViewChip(
            key: const ValueKey('view-new'),
            label: context.l10n.viewNew,
            icon: Icons.add_rounded,
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => ErbarioViewEditor(catalog: catalog),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _confirmRemove(BuildContext context, ErbarioViewsController views, SavedView view) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.xl, 0, Gaps.xl, Gaps.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(view.name, style: context.texts.titleLarge),
              const SizedBox(height: Gaps.l),
              FilledButton.icon(
                key: const ValueKey('view-remove'),
                onPressed: () {
                  views.remove(view.id);
                  Navigator.of(sheet).pop();
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(context.l10n.viewRemove),
              ),
            ],
          ),
        ),
      );
}

class _ViewChip extends StatelessWidget {
  final String label;
  final bool? selected;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ViewChip({super.key, required this.label, required this.onTap, this.selected, this.icon, this.onLongPress});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: Gaps.chip),
    child: GestureDetector(
      onLongPress: onLongPress,
      child: ClayChip(
        label: label,
        selected: selected,
        avatar: icon == null ? null : Icon(icon, size: 18),
        onTap: onTap,
      ),
    ),
  );
}

/// Foglio per creare una vista: un nome e i criteri. Si salva solo con un nome e almeno un criterio.
class ErbarioViewEditor extends StatefulWidget {
  final Catalog catalog;

  const ErbarioViewEditor({super.key, required this.catalog});

  @override
  State<ErbarioViewEditor> createState() => _ErbarioViewEditorState();
}

class _ErbarioViewEditorState extends State<ErbarioViewEditor> {
  final _name = TextEditingController();
  var _filter = ErbarioFilter.all;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Set<T> _toggle<T>(Set<T> set, T value) => set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final game = context.game;
    final families = widget.catalog.species.map((s) => s.family).toSet().toList()..sort();
    Widget section(String title, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(top: Gaps.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.texts.titleSmall),
          const SizedBox(height: Gaps.s),
          Wrap(spacing: Gaps.chip, runSpacing: Gaps.chipRun, children: chips),
        ],
      ),
    );
    final canSave = _name.text.trim().isNotEmpty && !_filter.isEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(Gaps.xl, 0, Gaps.xl, Gaps.xl),
          children: [
            Text(l10n.viewNew, style: context.texts.titleLarge),
            const SizedBox(height: Gaps.m),
            TextField(
              key: const ValueKey('view-name'),
              controller: _name,
              decoration: InputDecoration(labelText: l10n.viewName),
              onChanged: (_) => setState(() {}),
            ),
            section(l10n.viewStatus, [
              for (final status in SpeciesStatus.values)
                ClayChip(
                  key: ValueKey('filter-${status.name}'),
                  label: game.speciesStatus(status),
                  selected: _filter.statuses.contains(status),
                  onTap: () => setState(() => _filter = _filter.copyWith(statuses: _toggle(_filter.statuses, status))),
                ),
            ]),
            section(l10n.viewWhen, [
              ClayChip(
                key: const ValueKey('filter-inSeason'),
                label: game.builtInView(BuiltInView.inSeason),
                selected: _filter.inSeason,
                onTap: () => setState(() => _filter = _filter.copyWith(inSeason: !_filter.inSeason)),
              ),
              ClayChip(
                key: const ValueKey('filter-protected'),
                label: l10n.viewProtectedOnly,
                selected: _filter.protectedOnly,
                onTap: () => setState(() => _filter = _filter.copyWith(protectedOnly: !_filter.protectedOnly)),
              ),
            ]),
            section(l10n.viewBand, [
              for (final band in AltitudeBand.values)
                ClayChip(
                  key: ValueKey('filter-${band.name}'),
                  label: game.band(band),
                  selected: _filter.bands.contains(band),
                  onTap: () => setState(() => _filter = _filter.copyWith(bands: _toggle(_filter.bands, band))),
                ),
            ]),
            section(l10n.viewForm, [
              for (final form in GrowthForm.values)
                ClayChip(
                  key: ValueKey('filter-${form.name}'),
                  label: game.plantTrait(form),
                  selected: _filter.forms.contains(form),
                  onTap: () => setState(() => _filter = _filter.copyWith(forms: _toggle(_filter.forms, form))),
                ),
            ]),
            section(l10n.viewFamily, [
              for (final family in families)
                ClayChip(
                  label: family,
                  selected: _filter.families.contains(family),
                  onTap: () => setState(() => _filter = _filter.copyWith(families: _toggle(_filter.families, family))),
                ),
            ]),
            const SizedBox(height: Gaps.xl),
            FilledButton(
              key: const ValueKey('view-save'),
              onPressed: canSave
                  ? () {
                      Get.find<ErbarioViewsController>().add(_name.text, _filter);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Text(l10n.viewSave),
            ),
          ],
        ),
      ),
    );
  }
}
