import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/account/presentation/components/resource_card.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final _searchController = TextEditingController();
  int _category = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.resources.tr(context: context),
      child: FutureBuilder<List<ResourceItem>>(
        future: getIt<EtzanBackendRepository>().getResources(),
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
                  title: LocaleKeys.resourcesLoadError.tr(context: context),
                  body: LocaleKeys.checkSupabaseConnection.tr(context: context),
                ),
              ],
            );
          }

          final resources = snapshot.data ?? const <ResourceItem>[];
          final allLabel = LocaleKeys.all.tr(context: context);
          final categories = [
            allLabel,
            ...resources
                .map((item) => item.category)
                .where((item) => item.isNotEmpty)
                .toSet(),
          ];
          final selectedIndex =
              _category.clamp(0, categories.length - 1).toInt();
          final selectedCategory = categories[selectedIndex];
          final categorized = selectedCategory == allLabel
              ? resources
              : resources
                  .where((item) => item.category == selectedCategory)
                  .toList(growable: false);
          final query = _searchController.text.trim().toLowerCase();
          final visible = query.isEmpty
              ? categorized
              : categorized.where((item) {
                  final haystack = [
                    item.title,
                    item.description,
                    item.category,
                    item.type,
                  ].join(' ').toLowerCase();
                  return haystack.contains(query);
                }).toList(growable: false);

          return ListView(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: LocaleKeys.searchResources.tr(context: context),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    categories.length,
                    (index) => Padding(
                      padding:
                          const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                      child: EtzanTag(
                        label: categories[index],
                        selected: selectedIndex == index,
                        onTap: () => setState(() => _category = index),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              EtzanSectionTitle(
                title: LocaleKeys.etzanResources.tr(context: context),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (visible.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noSearchResults.tr(context: context),
                  body: LocaleKeys.tryDifferentSearchOrCategory.tr(
                    context: context,
                  ),
                )
              else
                AdaptiveGrid(
                  phone: 1,
                  tablet: 2,
                  desktop: 3,
                  children: visible
                      .map(
                        (item) => ResourceCard(
                          icon: _resourceIcon(item.type),
                          title: item.title,
                          meta: item.description.isEmpty
                              ? item.category
                              : item.description,
                          type: _resourceType(
                            context,
                            item.type,
                            isPremium: item.isPremium,
                          ),
                          contentUrl: item.contentUrl,
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _resourceIcon(String type) {
    if (type.contains('audio')) return Icons.graphic_eq;
    if (type.contains('course') || type.contains('program')) {
      return Icons.workspace_premium;
    }
    if (type.contains('video')) return Icons.video_library_outlined;
    return Icons.menu_book_outlined;
  }

  String _resourceType(
    BuildContext context,
    String type, {
    required bool isPremium,
  }) {
    final label = switch (type) {
      final value when value.contains('audio') =>
        LocaleKeys.audioSession.tr(context: context),
      final value when value.contains('course') || value.contains('program') =>
        LocaleKeys.course.tr(context: context),
      final value when value.contains('video') =>
        LocaleKeys.video.tr(context: context),
      _ => LocaleKeys.article.tr(context: context),
    };

    if (!isPremium) return label;
    return '$label • ${LocaleKeys.featured.tr(context: context)}';
  }
}
