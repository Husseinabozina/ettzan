import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Single entry point for localized UI copy.
///
/// Keep translation keys in `assets/translations/*.json`; never put visible
/// Arabic or English copy in widgets, cubits, or repositories.
abstract final class AppLocalization {
  static const path = 'assets/translations';
  static const fallbackLocale = Locale('ar');
  static const supportedLocales = [Locale('ar'), Locale('en')];
}

extension AppLocalizationContext on BuildContext {
  bool get isArabic => locale.languageCode == 'ar';
}
