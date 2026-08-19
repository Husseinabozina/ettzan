import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_shell.dart';
import 'package:etzan_life_coaching/features/journal/presentation/components/journal_entry_card.dart';

const journalFloatingActionListPadding = EdgeInsets.only(bottom: 112);

class JournalHomeScreen extends StatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  State<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends State<JournalHomeScreen> {
  late Future<List<JournalEntryItem>> _future =
      getIt<EtzanBackendRepository>().getJournalEntries();
  final _scrollController = ScrollController();
  bool _fabVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    if (offset > _lastScrollOffset + 8 && offset > 120) {
      if (_fabVisible) setState(() => _fabVisible = false);
    } else if (offset < _lastScrollOffset - 8 || offset <= 120) {
      if (!_fabVisible) setState(() => _fabVisible = true);
    }
    _lastScrollOffset = offset;
  }

  void _reload() {
    setState(() {
      _future = getIt<EtzanBackendRepository>().getJournalEntries();
    });
  }

  Future<void> _openNewEntry() async {
    await Navigator.of(context).pushNamed(AppRoutes.journalEntry);
    if (mounted) _reload();
  }

  Future<void> _openEntry(JournalEntryItem entry) async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.journalEntry, arguments: entry);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return EtzanShell(
      currentIndex: 3,
      title: LocaleKeys.journalHome.tr(context: context),
      actions: [
        IconButton(
          tooltip: LocaleKeys.progress.tr(context: context),
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.progress),
          icon: const Icon(Icons.insights),
        ),
      ],
      floatingActionButton: AnimatedScale(
        scale: _fabVisible ? 1 : 0,
        duration: AppDurations.fast,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _fabVisible ? 1 : 0,
          duration: AppDurations.fast,
          child: FloatingActionButton.extended(
            onPressed: _openNewEntry,
            icon: const Icon(Icons.edit_outlined),
            label: Text(LocaleKeys.newEntry.tr(context: context)),
          ),
        ),
      ),
      child: FutureBuilder<List<JournalEntryItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: journalFloatingActionListPadding,
              children: const [
                EtzanLoadingCard(),
                SizedBox(height: AppSpacing.sm),
                EtzanLoadingCard(),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              padding: journalFloatingActionListPadding,
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.journalLoadError.tr(context: context),
                  body: LocaleKeys.tryAgainLater.tr(context: context),
                ),
              ],
            );
          }

          final entries = snapshot.data ?? const <JournalEntryItem>[];

          return ListView(
            controller: _scrollController,
            padding: journalFloatingActionListPadding,
            children: [
              EtzanSectionTitle(
                title: LocaleKeys.recentReflections.tr(context: context),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (entries.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noJournalEntries.tr(context: context),
                  body: LocaleKeys.noJournalEntriesDescription.tr(
                    context: context,
                  ),
                )
              else
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: JournalEntryCard(
                      entry: entry,
                      onTap: () => _openEntry(entry),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              EtzanCard(
                gradient: AppColors.calmGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.writingPromptToday.tr(context: context),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      LocaleKeys.writingPromptQuestion.tr(context: context),
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
