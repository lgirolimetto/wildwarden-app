import 'dart:convert';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_catalog_repository.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:flutter/services.dart';

/// Catalogo incluso nell'app come asset (generato da `tools/content-pipeline/export_app_catalog.py`), con le
/// aromatiche del tutorial (`tools/content-pipeline/kitchen.py`).
class AssetCatalogRepository implements ICatalogRepository {
  static const bolognaAsset = 'assets/content/bologna/catalog.json';
  static const kitchenAsset = 'assets/content/kitchen/catalog.json';

  final AssetBundle _bundle;
  final String _assetPath;
  final String _kitchenPath;

  AssetCatalogRepository({AssetBundle? bundle, String assetPath = bolognaAsset, String kitchenPath = kitchenAsset})
    : _bundle = bundle ?? rootBundle,
      _assetPath = assetPath,
      _kitchenPath = kitchenPath;

  @override
  Future<Validation<Catalog>> loadCatalog() => _load().tryCatch().bind(
    (raw) => Try(
      () => Catalog.fromJson(
        jsonDecode(raw.$1) as Map<String, dynamic>,
        kitchen: jsonDecode(raw.$2) as Map<String, dynamic>,
      ),
    ),
  );

  Future<(String, String)> _load() async =>
      (await _bundle.loadString(_assetPath), await _bundle.loadString(_kitchenPath));
}
