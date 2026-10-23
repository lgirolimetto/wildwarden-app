import 'dart:convert';

import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:druid_app/business_logic/rules/erbario_views.dart';
import 'package:get/get.dart';

/// Viste dell'erbario: quelle già pronte e quelle salvate dall'utente, con la vista scelta. Si salvano nelle
/// preferenze del telefono: sono un modo personale di guardare l'erbario, non progressi di gioco.
class ErbarioViewsController extends GetxController {
  static const viewsKey = 'erbario.views';
  static const selectedKey = 'erbario.selectedView';

  final IPreferences _preferences;

  ErbarioViewsController(this._preferences);

  List<SavedView> saved = const [];

  /// Vista scelta: `builtin:<nome>` per quelle già pronte, l'id per quelle salvate.
  String selected = builtInKey(BuiltInView.all);

  static String builtInKey(BuiltInView view) => 'builtin:${view.name}';

  @override
  void onInit() {
    super.onInit();
    final raw = _preferences.getString(viewsKey);
    if (raw != null) {
      try {
        saved = [for (final view in jsonDecode(raw) as List) SavedView.fromJson(view as Map<String, dynamic>)];
      } on FormatException {
        saved = const [];
      }
    }
    final stored = _preferences.getString(selectedKey);
    if (stored != null && _filterOf(stored) != null) selected = stored;
  }

  ErbarioFilter get filter => _filterOf(selected) ?? ErbarioFilter.all;

  ErbarioFilter? _filterOf(String key) {
    for (final view in BuiltInView.values) {
      if (builtInKey(view) == key) return view.filter;
    }
    for (final view in saved) {
      if (view.id == key) return view.filter;
    }
    return null;
  }

  Future<void> select(String key) async {
    selected = key;
    update();
    await _preferences.setString(selectedKey, key);
  }

  /// Salva una nuova vista e la sceglie.
  Future<SavedView> add(String name, ErbarioFilter filter) async {
    final view = SavedView(id: 'v${DateTime.now().microsecondsSinceEpoch}', name: name.trim(), filter: filter);
    saved = [...saved, view];
    await _store();
    await select(view.id);
    return view;
  }

  Future<void> remove(String id) async {
    saved = saved.where((v) => v.id != id).toList();
    if (selected == id) selected = builtInKey(BuiltInView.all);
    update();
    await _store();
    await _preferences.setString(selectedKey, selected);
  }

  Future<void> _store() => _preferences.setString(viewsKey, jsonEncode([for (final v in saved) v.toJson()]));
}
