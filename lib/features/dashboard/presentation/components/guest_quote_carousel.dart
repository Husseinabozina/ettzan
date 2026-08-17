import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

/// A swipable carousel of short literary blurbs about balance.
class GuestQuoteCarousel extends StatefulWidget {
  const GuestQuoteCarousel({super.key});

  @override
  State<GuestQuoteCarousel> createState() => _GuestQuoteCarouselState();
}

class _GuestQuoteCarouselState extends State<GuestQuoteCarousel> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<String> _quotes = [
    LocaleKeys.guestQuoteOne,
    LocaleKeys.guestQuoteTwo,
    LocaleKeys.guestQuoteThree,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _controller,
            itemCount: _quotes.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: EtzanCard(
                gradient: index.isEven
                    ? AppColors.heroGradient
                    : AppColors.calmGradient,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 30,
                      color: AppColors.primary.withValues(alpha: .3),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _quotes[index].tr(context: context),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: AppColors.primaryDeep,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Text(
                        LocaleKeys.appName.tr(context: context),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _quotes.length,
            (index) => AnimatedContainer(
              duration: AppDurations.fast,
              width: index == _page ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: index == _page ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
