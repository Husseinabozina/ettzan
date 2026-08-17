import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.privacy.tr(context: context),
      child: ListView(
        children: [
          Text(
            LocaleKeys.privacyIntro.tr(context: context),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PrivacySection(
            title: LocaleKeys.privacyDataTitle.tr(context: context),
            body: LocaleKeys.privacyDataBody.tr(context: context),
          ),
          _PrivacySection(
            title: LocaleKeys.privacyUseTitle.tr(context: context),
            body: LocaleKeys.privacyUseBody.tr(context: context),
          ),
          _PrivacySection(
            title: LocaleKeys.privacySecurityTitle.tr(context: context),
            body: LocaleKeys.privacySecurityBody.tr(context: context),
          ),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: EtzanCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
