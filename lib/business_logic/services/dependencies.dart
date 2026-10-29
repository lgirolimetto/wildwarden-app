import 'dart:math';

import 'package:druid_app/business_logic/interfaces/i_catalog_repository.dart';
import 'package:druid_app/business_logic/interfaces/i_clock.dart';
import 'package:druid_app/business_logic/interfaces/i_field_test_log.dart';
import 'package:druid_app/business_logic/interfaces/i_frame_analyzer.dart';
import 'package:druid_app/business_logic/interfaces/i_game_event_store.dart';
import 'package:druid_app/business_logic/interfaces/i_location_sampler.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_source.dart';
import 'package:druid_app/business_logic/interfaces/i_link_opener.dart';
import 'package:druid_app/business_logic/interfaces/i_permissions.dart';
import 'package:druid_app/business_logic/interfaces/i_photo_store.dart';
import 'package:druid_app/business_logic/interfaces/i_plant_identifier.dart';
import 'package:druid_app/business_logic/interfaces/i_weather_service.dart';
import 'package:druid_app/business_logic/interfaces/i_preferences.dart';
import 'package:druid_app/business_logic/models/app_config.dart';
import 'package:druid_app/business_logic/services/camera/probe_frame_analyzer.dart';
import 'package:druid_app/business_logic/services/camera/system_camera_photo_source.dart';
import 'package:druid_app/business_logic/services/catalog/asset_catalog_repository.dart';
import 'package:druid_app/business_logic/services/clock/offset_clock.dart';
import 'package:druid_app/business_logic/services/field_test/file_field_test_log.dart';
import 'package:druid_app/business_logic/services/location/geolocator_sampler.dart';
import 'package:druid_app/business_logic/services/persistence/drift_game_event_store.dart';
import 'package:druid_app/business_logic/services/persistence/druid_database.dart';
import 'package:druid_app/business_logic/services/links/browser_link_opener.dart';
import 'package:druid_app/business_logic/services/permissions/device_permissions.dart';
import 'package:druid_app/business_logic/services/plantnet/plantnet_identifier.dart';
import 'package:druid_app/business_logic/services/weather/open_meteo_service.dart';
import 'package:druid_app/controllers/catalog/catalog_controller.dart';
import 'package:druid_app/controllers/erbario/erbario_views_controller.dart';
import 'package:druid_app/controllers/home/home_controller.dart';
import 'package:druid_app/controllers/progress/progress_controller.dart';
import 'package:druid_app/controllers/study/study_controller.dart';
import 'package:druid_app/controllers/subscription/subscription_controller.dart';
import 'package:druid_app/controllers/theme/theme_controller.dart';
import 'package:druid_app/user_interface/common_widgets/remote_image.dart';
import 'package:druid_app/user_interface/pages/camera/in_app_camera_photo_source.dart';
import 'package:get/get.dart';

/// Etichetta di GetX della fotocamera di sistema (l'[IPhotoSource] senza etichetta è quella dell'app).
const systemCameraTag = 'system-camera';

/// Registra servizi e controller globali. Unico contenitore di dipendenze: GetX.
///
/// I test passano implementazioni finte degli stessi tipi astratti, senza toccare il resto.
void registerDependencies({
  required AppConfig config,
  required IPreferences preferences,
  required IPhotoStore photoStore,
  ICatalogRepository? catalogRepository,
  IGameEventStore? eventStore,
  IClock? clock,
  Random? random,
  RemoteImageFactory? imageFactory,
  IPlantIdentifier? plantIdentifier,
  IPhotoSource? photoSource,
  IPhotoSource? systemPhotoSource,
  IFrameAnalyzer? frameAnalyzer,
  IWeatherService? weatherService,
  ILocationSampler? locationSampler,
  IFieldTestLog? fieldTestLog,
  IPermissions? permissions,
  ILinkOpener? linkOpener,
}) {
  Get.put<AppConfig>(config, permanent: true);
  Get.put<IPreferences>(preferences, permanent: true);
  Get.put<IPhotoStore>(photoStore, permanent: true);

  // Con gli strumenti di debug il tempo si può far avanzare ("fai passare i giorni").
  final baseClock = clock ?? const SystemClock();
  final effectiveClock = config.showDebugTools ? OffsetClock(baseClock, preferences) : baseClock;
  Get.put<IClock>(effectiveClock, permanent: true);
  if (effectiveClock is OffsetClock) Get.put<OffsetClock>(effectiveClock, permanent: true);

  Get.put<ICatalogRepository>(catalogRepository ?? AssetCatalogRepository(), permanent: true);
  Get.put<IGameEventStore>(eventStore ?? DriftGameEventStore(DruidDatabase.onDevice()), permanent: true);
  Get.put<RemoteImageFactory>(imageFactory ?? const CachedRemoteImageFactory(), permanent: true);
  Get.put<IPlantIdentifier>(plantIdentifier ?? PlantNetIdentifier(config), permanent: true);
  // Il gioco usa la fotocamera dell'app (capitolo 07); quella di sistema resta per il confronto nella Prova sul campo.
  Get.put<IPhotoSource>(photoSource ?? const InAppCameraPhotoSource(), permanent: true);
  Get.put<IPhotoSource>(systemPhotoSource ?? SystemCameraPhotoSource(), tag: systemCameraTag, permanent: true);
  Get.put<IFrameAnalyzer>(frameAnalyzer ?? ProbeFrameAnalyzer(), permanent: true);
  Get.put<IWeatherService>(weatherService ?? OpenMeteoService(config, effectiveClock), permanent: true);
  Get.put<ILocationSampler>(locationSampler ?? GeolocatorSampler(), permanent: true);
  Get.put<IFieldTestLog>(fieldTestLog ?? FileFieldTestLog(), permanent: true);
  Get.put<IPermissions>(permissions ?? const DevicePermissions(), permanent: true);
  Get.put<ILinkOpener>(linkOpener ?? const BrowserLinkOpener(), permanent: true);

  Get.put(ThemeController(Get.find()), permanent: true);
  Get.put(ErbarioViewsController(Get.find()), permanent: true);
  final catalogController = Get.put(CatalogController(Get.find()), permanent: true);
  final progress = Get.put(
    ProgressController(
      Get.find(),
      Get.find(),
      catalog: () => catalogController.uiData.fold((_) => null, (catalog) => catalog),
      random: random,
    ),
    permanent: true,
  );
  Get.put(SubscriptionController(Get.find()), permanent: true);
  Get.put(StudyController(progress, random: random), permanent: true);
  Get.put(HomeController(progress), permanent: true);
}
