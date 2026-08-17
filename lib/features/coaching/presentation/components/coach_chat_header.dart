import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class CoachChatHeader extends StatelessWidget {
  const CoachChatHeader({
    required this.coachName,
    required this.specialties,
    required this.onRefresh,
    super.key,
  });

  final String coachName;
  final List<String> specialties;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          EtzanAvatar(name: coachName, online: true),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.coachNameLabel.tr(
                    context: context,
                    namedArgs: {'name': coachName},
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  specialties.isEmpty
                      ? LocaleKeys.etzanCoach.tr(context: context)
                      : specialties.join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: LocaleKeys.refresh.tr(context: context),
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
