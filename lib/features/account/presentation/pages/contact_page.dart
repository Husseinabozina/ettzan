import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.contactUs.tr(context: context),
      child: ListView(
        children: [
          Text(
            LocaleKeys.contactIntro.tr(context: context),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          EtzanCard(
            child: Column(
              children: [
                _ContactTile(
                  icon: Icons.mail_outline,
                  label: LocaleKeys.contactEmailLabel.tr(context: context),
                  value:
                      LocaleKeys.contactEmailAddress.tr(context: context),
                  onTap: () => _copyValue(
                    context,
                    LocaleKeys.contactEmailAddress.tr(context: context),
                  ),
                ),
                const Divider(),
                _ContactTile(
                  icon: Icons.public,
                  label: LocaleKeys.contactWebsiteLabel.tr(context: context),
                  value:
                      LocaleKeys.contactWebsiteAddress.tr(context: context),
                  onTap: () => _copyValue(
                    context,
                    LocaleKeys.contactWebsiteAddress.tr(context: context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            LocaleKeys.contactEmailCopied.tr(context: context),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.inkSubtle),
          ),
        ],
      ),
    );
  }

  Future<void> _copyValue(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.contactEmailCopied.tr(context: context)),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(
        value,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.primaryDeep),
      ),
      trailing: const Icon(Icons.copy_outlined, size: 20),
      onTap: onTap,
    );
  }
}
