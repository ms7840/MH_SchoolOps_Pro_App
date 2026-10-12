import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';

/// Root application widget configuring routing and modern themes.
class SchoolOpsApp extends ConsumerWidget {
  const SchoolOpsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appConfig = AppConfig.instance;

    return MaterialApp.router(
      title: appConfig.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme(
        primaryColor: appConfig.flavorConfig.primaryColor,
        secondaryColor: appConfig.flavorConfig.secondaryColor,
      ),
      darkTheme: AppTheme.darkTheme(
        primaryColor: appConfig.flavorConfig.primaryColor,
        secondaryColor: appConfig.flavorConfig.secondaryColor,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
