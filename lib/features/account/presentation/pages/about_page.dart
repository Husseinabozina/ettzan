import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.aboutEtzan.tr(context: context),
      child: ListView(
        children: [
          EtzanCard(
            gradient: AppColors.calmGradient,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Image.asset(
                  AppAssets.etzanLogo,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  LocaleKeys.appName.tr(context: context),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: AppColors.primaryDeep,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  LocaleKeys.tagline.tr(context: context),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.primaryDark),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EtzanCard(
            child: Text(
              LocaleKeys.aboutDescription.tr(context: context),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
