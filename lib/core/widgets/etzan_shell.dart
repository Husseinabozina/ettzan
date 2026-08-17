import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/responsive/responsive.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_asset_icon.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_logo.dart';

class EtzanShell extends StatelessWidget {
  const EtzanShell({
    required this.currentIndex,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  final int currentIndex;
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  static const _routes = <String>[
    AppRoutes.home,
    AppRoutes.upcomingSessions,
    AppRoutes.goalsOverview,
    AppRoutes.journalHome,
    AppRoutes.profile,
  ];

  void _select(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.of(context).pushReplacementNamed(_routes[index]);
  }

  List<NavigationDestination> _destinations(BuildContext context) => [
        NavigationDestination(
          icon: const EtzanAssetIcon(AppAssets.iconHome,
              color: AppColors.inkMuted),
          selectedIcon: const EtzanAssetIcon(AppAssets.iconHome,
              color: AppColors.primaryDeep),
          label: LocaleKeys.home.tr(context: context),
        ),
        NavigationDestination(
          icon: const EtzanAssetIcon(AppAssets.iconCalendar,
              color: AppColors.inkMuted),
          selectedIcon: const EtzanAssetIcon(AppAssets.iconCalendar,
              color: AppColors.primaryDeep),
          label: LocaleKeys.sessions.tr(context: context),
        ),
        NavigationDestination(
          icon: const EtzanAssetIcon(AppAssets.iconTarget,
              color: AppColors.inkMuted),
          selectedIcon: const EtzanAssetIcon(AppAssets.iconTarget,
              color: AppColors.primaryDeep),
          label: LocaleKeys.goals.tr(context: context),
        ),
        NavigationDestination(
          icon: const EtzanAssetIcon(AppAssets.iconJournal,
              color: AppColors.inkMuted),
          selectedIcon: const EtzanAssetIcon(AppAssets.iconJournal,
              color: AppColors.primaryDeep),
          label: LocaleKeys.journal.tr(context: context),
        ),
        NavigationDestination(
          icon: const EtzanAssetIcon(AppAssets.iconProfile,
              color: AppColors.inkMuted),
          selectedIcon: const EtzanAssetIcon(AppAssets.iconProfile,
              color: AppColors.primaryDeep),
          label: LocaleKeys.more.tr(context: context),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    if (Responsive.isPhone(context)) {
      return Scaffold(
        appBar: AppBar(
          titleSpacing: AppSpacing.md,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: actions,
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
            boxShadow: [
              BoxShadow(
                color: Color(0x12102A47),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: currentIndex,
              destinations: _destinations(context),
              onDestinationSelected: (index) => _select(context, index),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: ResponsiveCenter(
            child: Padding(
              padding: Responsive.pagePadding(context),
              child: child,
            ),
          ),
        ),
      );
    }

    final railItems = _destinations(context)
        .map((item) => NavigationRailDestination(
            icon: item.icon,
            selectedIcon: item.selectedIcon,
            label: Text(item.label)))
        .toList();

    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => _select(context, index),
              labelType: Responsive.isDesktop(context)
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              extended: Responsive.isDesktop(context),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const EtzanLogo(compact: true),
                    if (Responsive.isDesktop(context)) ...[
                      const SizedBox(width: 10),
                      Text(LocaleKeys.appName.tr(context: context),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primaryDark)),
                    ],
                  ],
                ),
              ),
              destinations: railItems,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  AppBar(
                      title: Text(title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      actions: actions),
                  Expanded(
                    child: ResponsiveCenter(
                      child: Padding(
                        padding: Responsive.pagePadding(context),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
