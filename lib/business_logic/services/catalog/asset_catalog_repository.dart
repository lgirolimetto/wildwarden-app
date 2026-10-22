import 'dart:convert';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/business_logic/interfaces/i_catalog_repository.dart';
import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:flutter/services.dart';

/// Catalogo incluso nell'app come asset (generato da `tools/content-pipeline/export_app_catalog.py`).
class AssetCatalogRepository implements ICatalogRepository {
  static const bolognaAsset = 'assets/content/bologna/catalog.json';

  final AssetBundle _bundle;
  final String _assetPath;

  AssetCatalogRepository({AssetBundle? bundle, String assetPath = bolognaAsset})
    : _bundle = bundle ?? rootBundle,
      _assetPath = assetPath;

  @override
  Future<Validation<Catalog>> loadCatalog() => _bundle
      .loadString(_assetPath)
      .tryCatch()
      .bind((raw) => Try(() => Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>)));
}
