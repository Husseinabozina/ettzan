import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coaching_labels.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    super.key,
  });

  final ChatMessageItem message;

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        message.isMine ? AppColors.primary : AppColors.surface;
    final textColor = message.isMine ? Colors.white : AppColors.ink;

    return Align(
      alignment: message.isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          border: Border.all(
            color: message.isMine ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(AppRadii.md),
            topEnd: const Radius.circular(AppRadii.md),
            bottomStart:
                Radius.circular(message.isMine ? AppRadii.md : AppRadii.xs),
            bottomEnd:
                Radius.circular(message.isMine ? AppRadii.xs : AppRadii.md),
          ),
          boxShadow: message.isMine ? AppShadows.soft : AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  coachingTimeLabel(context, message.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: message.isMine
                            ? Colors.white.withValues(alpha: .78)
                            : AppColors.inkSubtle,
                      ),
                ),
                if (message.isPending) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      color: Colors.white.withValues(alpha: .78),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
