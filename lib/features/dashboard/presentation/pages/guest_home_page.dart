import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_shell.dart';

import 'package:etzan_life_coaching/features/dashboard/presentation/components/guest_quote_carousel.dart';

class GuestHomePage extends StatelessWidget {
  const GuestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return EtzanShell(
      currentIndex: 0,
      title: LocaleKeys.home.tr(context: context),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
          child: Text(LocaleKeys.signInToContinue.tr(context: context)),
        ),
      ],
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          EtzanCard(
            gradient: AppColors.calmGradient,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EtzanTag(
                  label: LocaleKeys.guestMode.tr(context: context),
                  selected: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  LocaleKeys.guestHomeTitle.tr(context: context),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LocaleKeys.guestHomeBody.tr(context: context),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.inkMuted),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoutes.discoverCoaches),
                      icon: const Icon(Icons.people_outline),
                      label: Text(
                        LocaleKeys.guestBrowseCoaches.tr(context: context),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.resources),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: Text(
                        LocaleKeys.guestBrowseResources.tr(context: context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const GuestQuoteCarousel(),
          const SizedBox(height: AppSpacing.lg),
          AdaptiveGrid(
            phone: 1,
            tablet: 3,
            desktop: 3,
            children: [
              EtzanIconTile(
                iconAsset: AppAssets.iconPeople,
                color: AppColors.primary,
                label: LocaleKeys.guestBrowseCoaches.tr(context: context),
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.discoverCoaches),
              ),
              EtzanIconTile(
                iconAsset: AppAssets.iconBook,
                color: AppColors.lavender,
                label: LocaleKeys.guestBrowseResources.tr(context: context),
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.resources),
              ),
              EtzanIconTile(
                iconAsset: AppAssets.iconSparkle,
                color: AppColors.warning,
                label: LocaleKeys.guestCreateAccountBenefit.tr(
                  context: context,
                ),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.signUp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
