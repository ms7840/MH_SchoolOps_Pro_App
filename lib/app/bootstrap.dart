import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../core/config/flavor_config.dart';
import '../core/network/http_overrides.dart';
import '../core/storage/local_cache_service.dart';
import 'app.dart';

/// Pre-flight initialization prior to widget tree attachment.
Future<void> bootstrap([FlavorConfig? flavorConfig]) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize flavor configuration
  if (flavorConfig != null) {
    AppConfig.initialize(flavorConfig);
    if (flavorConfig.flavor == Flavor.development) {
      configureDevHttpOverrides();
    }
  }

  // 2. Initialize local offline cache (Hive boxes)
  final localCache = LocalCacheService();
  await localCache.init();

  // 3. System UI Overlay settings for modern edge-to-edge feel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 4. Attach app with root Riverpod ProviderScope
  runApp(
    const ProviderScope(
      child: SchoolOpsApp(),
    ),
  );
}
