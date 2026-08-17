import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class SignInRequiredPage extends StatelessWidget {
  const SignInRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.guestMode.tr(context: context),
      child: ListView(
        children: [
          const SizedBox(height: 88),
          EtzanEmptyState(
            title: LocaleKeys.signInRequiredTitle.tr(context: context),
            body: LocaleKeys.signInRequiredBody.tr(context: context),
            action: Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.signUp, (_) => false),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: Text(
                    LocaleKeys.createAccountToContinue.tr(context: context),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
                  icon: const Icon(Icons.login),
                  label: Text(LocaleKeys.signInToContinue.tr(context: context)),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
                  icon: const Icon(
                    Icons.home_outlined,
                    color: AppColors.primary,
                  ),
                  label: Text(LocaleKeys.backHome.tr(context: context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
