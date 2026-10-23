import 'dart:math';

import 'package:druid_app/business_logic/interfaces/i_catalog_repository.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_game_event_store.dart';
import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/services/catalog/asset_catalog_repository.dart';
import 'package:druid_app/business_logic/services/clock/offset_clock.dart';
import 'package:druid_app/business_logic/services/persistence/drift_game_event_store.dart';
import 'package:druid_app/business_logic/services/persistence/druid_database.dart';
import 'package:druid_app/controllers/catalog/catalog_controller.dart';
import 'package:druid_app/controllers/erbario/erbario_views_controller.dart';
import 'package:druid_app/controllers/home/home_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/controllers/study/study_controller.dart';
import 'package:druid_app/controllers/subscription/subscription_controller.dart';
import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:get/get.dart';

/// Registra servizi e controller globali. Unico contenitore di dipendenze: GetX.
///
/// I test passano implementazioni finte degli stessi tipi astratti, senza toccare il resto.
void registerDependencies({
  required AppConfig config,
  required IPreferences preferences,
  ICatalogRepository? catalogRepository,
  IGameEventStore? eventStore,
  IClock? clock,
  Random? random,
  RemoteImageFactory? imageFactory,
}) {
  Get.put<AppConfig>(config, permanent: true);
  Get.put<IPreferences>(preferences, permanent: true);

  // Con gli strumenti di debug il tempo si può far avanzare ("fai passare i giorni").
  final baseClock = clock ?? const SystemClock();
  final effectiveClock = config.showDebugTools ? OffsetClock(baseClock, preferences) : baseClock;
  Get.put<IClock>(effectiveClock, permanent: true);
  if (effectiveClock is OffsetClock) Get.put<OffsetClock>(effectiveClock, permanent: true);

  Get.put<ICatalogRepository>(catalogRepository ?? AssetCatalogRepository(), permanent: true);
  Get.put<IGameEventStore>(eventStore ?? DriftGameEventStore(DruidDatabase.onDevice()), permanent: true);
  Get.put<RemoteImageFactory>(imageFactory ?? const CachedRemoteImageFactory(), permanent: true);

  Get.put(ThemeController(Get.find()), permanent: true);
  Get.put(ErbarioViewsController(Get.find()), permanent: true);
  final catalogController = Get.put(CatalogController(Get.find()), permanent: true);
  final progress = Get.put(
    ProgressController(
      Get.find(),
      Get.find(),
      catalog: () => catalogController.uiData.fold((_) => null, (catalog) => catalog),
    ),
    permanent: true,
  );
  Get.put(SubscriptionController(Get.find()), permanent: true);
  Get.put(StudyController(progress, random: random), permanent: true);
  Get.put(HomeController(progress), permanent: true);
}
