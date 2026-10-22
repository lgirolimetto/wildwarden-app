import 'package:druid_app/user_interface/theme/liveries/erbario_livery.dart';
import 'package:druid_app/user_interface/theme/liveries/notturna_livery.dart';
import 'package:druid_app/user_interface/theme/liveries/sottobosco_livery.dart';
import 'package:druid_app/user_interface/theme/livery.dart';

/// Elenco delle livree disponibili. La prima è quella di default.
abstract final class LiveryRegistry {
  static const List<Livery> all = [SottoboscoLivery(), ErbarioLivery(), NotturnaLivery()];

  static Livery get fallback => all.first;

  static Livery byId(String? id) => all.firstWhere((l) => l.id == id, orElse: () => fallback);
}
