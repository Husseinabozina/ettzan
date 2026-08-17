import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etzan_life_coaching/app/app.dart';
import 'package:etzan_life_coaching/core/config/app_environment.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  _ignoreEmulatorHardwareKeyboardAssertionsInDebug();

  await Supabase.initialize(
    url: AppEnvironment.supabaseUrl,
    publishableKey: AppEnvironment.supabasePublishableKey,
  );

  await configureDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: AppLocalization.supportedLocales,
      path: AppLocalization.path,
      fallbackLocale: AppLocalization.fallbackLocale,
      startLocale: AppLocalization.fallbackLocale,
      child: const EtzanBootstrap(),
    ),
  );
}

void _ignoreEmulatorHardwareKeyboardAssertionsInDebug() {
  if (!kDebugMode) return;

  final previousFlutterErrorHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    if (_isEmulatorHardwareKeyboardAssertion(
        details.exception, details.stack)) {
      debugPrint('Ignored Flutter emulator hardware keyboard assertion.');
      return;
    }

    if (previousFlutterErrorHandler != null) {
      previousFlutterErrorHandler(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    if (_isEmulatorHardwareKeyboardAssertion(error, stack)) {
      debugPrint('Ignored Flutter emulator hardware keyboard assertion.');
      return true;
    }

    return previousPlatformErrorHandler?.call(error, stack) ?? false;
  };
}

bool _isEmulatorHardwareKeyboardAssertion(Object error, StackTrace? stack) {
  final details = '$error\n$stack';

  return details.contains('hardware_keyboard.dart') &&
      details.contains('physical key') &&
      (details.contains('KeyUpEvent is dispatched') ||
          details.contains('KeyDownEvent is dispatched')) &&
      (details.contains('_pressedKeys') || details.contains('already pressed'));
}
