import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';

abstract final class AppTheme {
  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    final themed = GoogleFonts.tajawalTextTheme(base);
    final primaryText = brightness == Brightness.light
        ? AppColors.ink
        : const Color(0xFFF4F7FB);
    final secondaryText = brightness == Brightness.light
        ? AppColors.inkMuted
        : const Color(0xFFB9C4D2);

    return themed.copyWith(
      displaySmall: themed.displaySmall?.copyWith(
        fontSize: 36,
        height: 1.16,
        fontWeight: FontWeight.w800,
        color: primaryText,
      ),
      headlineMedium: themed.headlineMedium?.copyWith(
        fontSize: 28,
        height: 1.28,
        fontWeight: FontWeight.w800,
        color: primaryText,
      ),
      headlineSmall: themed.headlineSmall?.copyWith(
        fontSize: 23,
        height: 1.3,
        fontWeight: FontWeight.w800,
        color: primaryText,
      ),
      titleLarge: themed.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.35,
        fontWeight: FontWeight.w800,
        color: primaryText,
      ),
      titleMedium: themed.titleMedium?.copyWith(
        fontSize: 17,
        height: 1.42,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      titleSmall: themed.titleSmall?.copyWith(
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      bodyLarge: themed.bodyLarge?.copyWith(
        fontSize: 17,
        height: 1.7,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      bodyMedium: themed.bodyMedium?.copyWith(
        fontSize: 15,
        height: 1.62,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      ),
      bodySmall: themed.bodySmall?.copyWith(
        fontSize: 13.5,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      ),
      labelLarge: themed.labelLarge?.copyWith(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w800,
      ),
      labelMedium: themed.labelMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static ThemeData light() {
    final textTheme = _textTheme(Brightness.light);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.lavender,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        toolbarHeight: 72,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.card,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
          side: BorderSide(color: AppColors.divider),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkSubtle),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 58),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        elevation: 12,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        actionTextColor: AppColors.primaryDeep,
        insetPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          104,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.divider),
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondary.withValues(alpha: .42),
        surfaceTintColor: Colors.transparent,
        height: 78,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryDeep
                : AppColors.inkMuted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData dark() {
    final light = AppTheme.light();
    final textTheme = _textTheme(Brightness.dark);
    const darkSurface = Color(0xFF142235);
    const darkDivider = Color(0xFF24364E);
    return light.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0C1724),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0C1724),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFFF4F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: darkSurface,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
          side: BorderSide(color: darkDivider),
        ),
      ),
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: darkSurface,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
          borderSide: BorderSide(color: darkDivider),
        ),
      ),
      snackBarTheme: light.snackBarTheme.copyWith(
        backgroundColor: darkSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFF4F7FB),
          fontWeight: FontWeight.w700,
        ),
        actionTextColor: AppColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: darkDivider),
        ),
      ),
      navigationBarTheme: light.navigationBarTheme.copyWith(
        backgroundColor: darkSurface,
        indicatorColor: const Color(0x330FA398),
      ),
    );
  }
}
