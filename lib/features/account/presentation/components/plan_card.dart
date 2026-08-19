import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/account/presentation/components/plan_labels.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.title,
    required this.price,
    required this.features,
    required this.action,
    required this.onChoose,
    this.selected = false,
    this.isBusy = false,
    this.paymentPending = false,
    this.highlighted = false,
    super.key,
  });

  factory PlanCard.fromPlan(
    BuildContext context,
    SubscriptionPlanItem plan, {
    required bool yearly,
    required bool highlighted,
    required bool selected,
    required bool isBusy,
    required VoidCallback onChoose,
  }) {
    final amount = yearly ? plan.yearlyPrice : plan.monthlyPrice;
    final cadence = yearly
        ? LocaleKeys.year.tr(context: context)
        : LocaleKeys.month.tr(context: context);
    final paymentPending = amount > 0;
    return PlanCard(
      title: plan.name.isEmpty ? plan.code : plan.name,
      price: amount == 0
          ? LocaleKeys.free.tr(context: context)
          : '${amount.toStringAsFixed(0)} '
              '${LocaleKeys.sar.tr(context: context)} / $cadence',
      features: plan.features.isEmpty
          ? [LocaleKeys.planAvailableFromSupabase.tr(context: context)]
          : plan.features,
      action: selected
          ? LocaleKeys.currentPlan.tr(context: context)
          : isBusy
              ? LocaleKeys.saving.tr(context: context)
              : paymentPending
                  ? LocaleKeys.paymentPending.tr(context: context)
                  : LocaleKeys.choosePlan.tr(context: context),
      highlighted: highlighted,
      selected: selected,
      isBusy: isBusy,
      paymentPending: paymentPending,
      onChoose: onChoose,
    );
  }

  final String title;
  final String price;
  final List<String> features;
  final String action;
  final VoidCallback onChoose;
  final bool selected;
  final bool isBusy;
  final bool paymentPending;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      gradient: highlighted ? AppColors.calmGradient : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              if (highlighted)
                const Icon(Icons.star_rounded, color: AppColors.lavender),
              if (selected) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.verified, color: AppColors.success),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const Divider(height: 32),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 10),
                  Expanded(child: Text(planFeatureLabel(context, feature))),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (selected)
            FilledButton.tonalIcon(
              onPressed: null,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(action),
            )
          else if (paymentPending)
            FilledButton.tonalIcon(
              onPressed: null,
              icon: const Icon(Icons.lock_clock_outlined),
              label: Text(action),
            )
          else if (highlighted)
            EtzanPrimaryButton(
                label: action, onPressed: isBusy ? null : onChoose)
          else
            OutlinedButton(
              onPressed: isBusy ? null : onChoose,
              child: Text(action),
            ),
        ],
      ),
    );
  }
}
