import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class ProfileShortcutsGrid extends StatelessWidget {
  const ProfileShortcutsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveGrid(
      phone: 2,
      tablet: 4,
      desktop: 4,
      children: [
        EtzanIconTile(
          icon: Icons.menu_book_outlined,
          label: LocaleKeys.resources.tr(context: context),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.resources),
        ),
        EtzanIconTile(
          icon: Icons.workspace_premium,
          label: LocaleKeys.subscription.tr(context: context),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.subscription),
        ),
        EtzanIconTile(
          icon: Icons.notifications_none,
          label: LocaleKeys.notifications.tr(context: context),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
        ),
        EtzanIconTile(
          icon: Icons.settings_outlined,
          label: LocaleKeys.settings.tr(context: context),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
        ),
      ],
    );
  }
}
