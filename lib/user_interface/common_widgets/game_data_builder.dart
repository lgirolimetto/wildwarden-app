import 'package:druid_app/business_logic/models/catalog.dart';
import 'package:druid_app/business_logic/rules/game_state.dart';
import 'package:druid_app/controllers/catalog/catalog_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/user_interface/common_widgets/validation_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Catalogo e progressi insieme: le pagine di gioco hanno bisogno di entrambi. Mostra caricamento ed errori
/// con `ValidationView` e si ricostruisce quando uno dei due cambia.
class GameDataBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Catalog catalog, GameState state, ProgressController progress) builder;

  const GameDataBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => GetBuilder<CatalogController>(
    builder: (catalogController) => GetBuilder<ProgressController>(
      builder: (progress) => ValidationView<({Catalog catalog, GameState state})>(
        data: catalogController.uiData.bind(
          (catalog) => progress.uiData.map((state) => (catalog: catalog, state: state)),
        ),
        loading: catalogController.loading || progress.loading,
        onRetry: () {
          catalogController.load();
          progress.load();
        },
        builder: (context, value) => builder(context, value.catalog, value.state, progress),
      ),
    ),
  );
}
