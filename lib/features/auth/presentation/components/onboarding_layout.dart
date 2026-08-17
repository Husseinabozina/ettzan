import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/responsive/responsive.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';

class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    required this.title,
    required this.body,
    required this.illustrationAsset,
    required this.pageIndex,
    required this.onNext,
    super.key,
  });

  final String title;
  final String body;
  final String illustrationAsset;
  final int pageIndex;
  final VoidCallback onNext;

  Future<void> _continueAsGuest(BuildContext context) async {
    try {
      await getIt<AuthRepository>().signInAsGuest();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.guestSignInError.tr(context: context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final illustrationHeight = screenHeight < 700 ? 245.0 : 315.0;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: ResponsiveCenter(
            child: Padding(
              padding: Responsive.pagePadding(context),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.signUp),
                      child: Text(LocaleKeys.skip.tr(context: context)),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: screenHeight - 230,
                          maxWidth: 620,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EtzanHeroIllustration(
                              asset: illustrationAsset,
                              height: illustrationHeight,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: Text(
                                body,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppColors.inkMuted),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => AnimatedContainer(
                        duration: AppDurations.normal,
                        width: index == pageIndex ? 34 : 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == pageIndex
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  EtzanPrimaryButton(
                    label: LocaleKeys.next.tr(context: context),
                    iconAsset: AppAssets.iconArrow,
                    onPressed: onNext,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: () => _continueAsGuest(context),
                    child: Text(
                      LocaleKeys.continueAsGuest.tr(context: context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
