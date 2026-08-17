import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';

class EtzanLogo extends StatelessWidget {
  const EtzanLogo({
    this.compact = false,
    this.showWordmark = true,
    this.size,
    super.key,
  });

  final bool compact;
  final bool showWordmark;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? (compact ? 52.0 : 92.0);
    return Semantics(
      label: LocaleKeys.appName.tr(context: context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.etzanSymbol,
            width: resolvedSize,
            height: resolvedSize,
            fit: BoxFit.contain,
          ),
          if (showWordmark && !compact) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              LocaleKeys.appName.tr(context: context),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
