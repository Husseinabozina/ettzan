import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/growth_labels.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _milestones = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final _categoryKeys = const [
    LocaleKeys.goalSelfDevelopment,
    LocaleKeys.goalHealthFitness,
    LocaleKeys.goalMoneyInvestment,
    LocaleKeys.goalRelationships,
    LocaleKeys.goalLearning,
    LocaleKeys.goalSpirituality,
  ];
  int _category = 0;
  DateTime? _targetDate;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _milestones) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.goalTitleRequired.tr(context: context)),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await getIt<EtzanBackendRepository>().createGoal(
        title: title,
        description: _descriptionController.text.trim(),
        category: _categoryKeys[_category].tr(context: context),
        targetDate: _targetDate,
        milestones: _milestones.map((controller) => controller.text).toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.goalCreateError.tr(context: context)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.createGoal.tr(context: context),
      child: ListView(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: LocaleKeys.goalTitle.tr(context: context),
              hintText: LocaleKeys.goalTitleHint.tr(context: context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: LocaleKeys.shortDescription.tr(context: context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EtzanSectionTitle(title: LocaleKeys.category.tr(context: context)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _categoryKeys.length,
              (index) => EtzanTag(
                label: _categoryKeys[index].tr(context: context),
                selected: _category == index,
                onTap: () => setState(() => _category = index),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            readOnly: true,
            onTap: () async {
              final now = DateTime.now();
              final selected = await showDatePicker(
                context: context,
                initialDate: _targetDate ?? now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365 * 2)),
              );
              if (selected != null) setState(() => _targetDate = selected);
            },
            decoration: InputDecoration(
              labelText: LocaleKeys.targetDate.tr(context: context),
              hintText:
                  _targetDate == null ? null : growthDateLabel(_targetDate!),
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EtzanSectionTitle(title: LocaleKeys.milestones.tr(context: context)),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(
            _milestones.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: TextField(
                controller: _milestones[index],
                decoration: InputDecoration(
                  labelText: LocaleKeys.milestoneNumber.tr(
                    context: context,
                    namedArgs: {'number': '${index + 1}'},
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () =>
                  setState(() => _milestones.add(TextEditingController())),
              icon: const Icon(Icons.add),
              label: Text(LocaleKeys.addMilestone.tr(context: context)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EtzanPrimaryButton(
            label: _saving
                ? LocaleKeys.saving.tr(context: context)
                : LocaleKeys.createGoal.tr(context: context),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
