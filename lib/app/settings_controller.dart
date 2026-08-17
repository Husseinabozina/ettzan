import 'package:flutter/material.dart';

class AppSettingsController extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    required AppSettingsController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found in the widget tree.');
    return scope!.notifier!;
  }
}
