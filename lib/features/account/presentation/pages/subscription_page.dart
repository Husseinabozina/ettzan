import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/account/presentation/components/plan_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _yearly = true;
  String? _savingPlanId;
  late Future<_SubscriptionCatalog> _future = _loadCatalog();

  Future<_SubscriptionCatalog> _loadCatalog() async {
    final repository = getIt<EtzanBackendRepository>();
    final results = await Future.wait<dynamic>([
      repository.getSubscriptionPlans(),
      repository.getCurrentSubscriptionPlanId(),
    ]);
    return _SubscriptionCatalog(
      plans: results[0] as List<SubscriptionPlanItem>,
      currentPlanId: results[1] as String?,
    );
  }

  Future<void> _choosePlan(SubscriptionPlanItem plan) async {
    setState(() => _savingPlanId = plan.id);
    try {
      await getIt<EtzanBackendRepository>().chooseSubscriptionPlan(plan.id);
      if (!mounted) return;
      setState(() {
        _future = _loadCatalog();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.planSelected.tr(
              context: context,
              namedArgs: {'name': plan.name},
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.planSelectionError.tr(context: context)),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingPlanId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.subscription.tr(context: context),
      child: FutureBuilder<_SubscriptionCatalog>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              children: [
                const EtzanLoadingCard(),
                const SizedBox(height: AppSpacing.sm),
                const EtzanLoadingCard(),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.subscriptionsLoadError.tr(context: context),
                  body: LocaleKeys.checkSubscriptionPlans.tr(context: context),
                ),
              ],
            );
          }

          final catalog = snapshot.data ?? const _SubscriptionCatalog();
          final plans = catalog.plans;
          return ListView(
            children: [
              EtzanSegmentedControl<bool>(
                items: {
                  false: LocaleKeys.monthly.tr(context: context),
                  true: LocaleKeys.yearly.tr(context: context),
                },
                selected: _yearly,
                onChanged: (value) => setState(() => _yearly = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (plans.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noActivePlans.tr(context: context),
                  body: LocaleKeys.noActivePlansDescription.tr(
                    context: context,
                  ),
                )
              else
                AdaptiveGrid(
                  phone: 1,
                  tablet: 2,
                  desktop: 2,
                  children: plans
                      .map(
                        (plan) => PlanCard.fromPlan(
                          context,
                          plan,
                          yearly: _yearly,
                          highlighted: plan.code.contains('premium') ||
                              plan.code.contains('pro'),
                          selected: catalog.currentPlanId == plan.id,
                          isBusy: _savingPlanId == plan.id,
                          onChoose: () => _choosePlan(plan),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: AppSpacing.lg),
              EtzanCard(
                gradient: AppColors.calmGradient,
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primary,
                      size: 42,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        LocaleKeys.paymentGatewayPending.tr(context: context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SubscriptionCatalog {
  const _SubscriptionCatalog({
    this.plans = const <SubscriptionPlanItem>[],
    this.currentPlanId,
  });

  final List<SubscriptionPlanItem> plans;
  final String? currentPlanId;
}
