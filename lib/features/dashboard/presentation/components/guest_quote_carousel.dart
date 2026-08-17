import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

/// A swipable carousel of short literary blurbs about balance.
///
/// Quotes come from the `guest_quotes` table in Supabase; if the fetch fails
/// or the table is empty, the app falls back to the bundled translations.
class GuestQuoteCarousel extends StatefulWidget {
  const GuestQuoteCarousel({super.key});

  @override
  State<GuestQuoteCarousel> createState() => _GuestQuoteCarouselState();
}

class _GuestQuoteCarouselState extends State<GuestQuoteCarousel> {
  final PageController _controller = PageController();
  late final Future<List<GuestQuote>> _quotesFuture = _load();
  int _page = 0;

  static const List<String> _fallbackKeys = [
    LocaleKeys.guestQuoteOne,
    LocaleKeys.guestQuoteTwo,
    LocaleKeys.guestQuoteThree,
  ];

  Future<List<GuestQuote>> _load() =>
      getIt<EtzanBackendRepository>().getGuestQuotes();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GuestQuote>>(
      future: _quotesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: EtzanLoadingCard(height: 168),
          );
        }

        final quotes = snapshot.data ?? const <GuestQuote>[];
        final texts = quotes.isEmpty
            ? _fallbackKeys.map((key) => key.tr(context: context)).toList()
            : quotes
                .map((quote) => context.locale.languageCode == 'ar'
                    ? quote.textAr
                    : quote.textEn)
                .toList();

        return _buildCarousel(context, texts);
      },
    );
  }

  Widget _buildCarousel(BuildContext context, List<String> texts) {
    final count = texts.length;
    final page = _page.clamp(0, count - 1);

    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _controller,
            itemCount: count,
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
                        texts[index],
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
            count,
            (index) => AnimatedContainer(
              duration: AppDurations.fast,
              width: index == page ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: index == page ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
