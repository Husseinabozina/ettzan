import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/account/presentation/pages/resource_web_view_page.dart';

class ResourceCard extends StatelessWidget {
  const ResourceCard({
    required this.icon,
    required this.title,
    required this.meta,
    required this.type,
    this.contentUrl,
    super.key,
  });

  final IconData icon;
  final String title;
  final String meta;
  final String type;
  final String? contentUrl;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      onTap: () => _openResource(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.calmGradient,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Center(
              child: Icon(icon, size: 58, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            type,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(meta),
        ],
      ),
    );
  }

  void _openResource(BuildContext context) {
    final rawUrl = contentUrl?.trim();
    final uri = rawUrl == null || rawUrl.isEmpty ? null : Uri.tryParse(rawUrl);
    final canOpen = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'https' || uri.scheme == 'http');

    if (canOpen) {
      Navigator.of(context).pushNamed(
        AppRoutes.resourceViewer,
        arguments: ResourceViewerArgs(
          title: title,
          type: type,
          url: uri.toString(),
        ),
      );
      return;
    }

    _showResourceDetails(context);
  }

  void _showResourceDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    child: Icon(icon, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              EtzanTag(label: type, selected: true),
              const SizedBox(height: AppSpacing.md),
              Text(meta),
              const SizedBox(height: AppSpacing.lg),
              if (contentUrl == null || contentUrl!.trim().isEmpty)
                Text(LocaleKeys.resourceHasNoUrl.tr(context: context))
              else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contentUrl!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: contentUrl!),
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              LocaleKeys.resourceLinkCopied.tr(
                                context: context,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(LocaleKeys.copy.tr(context: context)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
