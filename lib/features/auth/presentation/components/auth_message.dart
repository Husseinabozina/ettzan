import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';

/// Translates known auth failure keys; external messages pass through as-is.
String authMessage(BuildContext context, String message) {
  return switch (message) {
    LocaleKeys.authSessionRefreshError ||
    LocaleKeys.unexpectedAuthError ||
    LocaleKeys.completeGoogleSignIn ||
    LocaleKeys.googleSignInStartError ||
    LocaleKeys.guestSignInError ||
    LocaleKeys.authSignUpFailed ||
    LocaleKeys.authSignUpLoginFailed ||
    LocaleKeys.authSignInFailed ||
    LocaleKeys.googleOpenError ||
    LocaleKeys.authTimeout ||
    LocaleKeys.signupTimeout ||
    LocaleKeys.googleTimeout =>
      message.tr(context: context),
    _ => message,
  };
}
