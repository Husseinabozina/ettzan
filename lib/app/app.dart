import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/app/app_router.dart';
import 'package:etzan_life_coaching/app/settings_controller.dart';
import 'package:etzan_life_coaching/core/design_system/app_theme.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';

class EtzanBootstrap extends StatefulWidget {
  const EtzanBootstrap({super.key});

  @override
  State<EtzanBootstrap> createState() => _EtzanBootstrapState();
}

class _EtzanBootstrapState extends State<EtzanBootstrap> {
  final AppSettingsController _settings = AppSettingsController();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: _settings,
      child: AnimatedBuilder(
        animation: _settings,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // `MaterialApp.title` is resolved before its localization subtree
            // exists. Use Easy Localization's initialized global resolver here.
            title: LocaleKeys.appName.tr(),
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _settings.themeMode,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
