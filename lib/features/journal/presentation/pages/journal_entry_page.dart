import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/journal/presentation/components/journal_labels.dart';
import 'package:etzan_life_coaching/features/journal/presentation/components/journal_mood_selector.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({this.entry, super.key});

  final JournalEntryItem? entry;

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final Set<String> _tags = {journalDefaultTagValue};

  int _moodIndex = 3;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry != null) {
      _titleController.text = entry.title == 'بدون عنوان' ? '' : entry.title;
      _bodyController.text = entry.body;
      _moodIndex = (entry.mood - 1).clamp(0, 4);
      _tags
        ..clear()
        ..addAll(entry.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.entry != null;

  Future<void> _save() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.journalBodyRequired.tr(context: context),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repository = getIt<EtzanBackendRepository>();
      if (_isEditing) {
        await repository.updateJournalEntry(
          entryId: widget.entry!.id,
          title: _titleController.text.trim(),
          body: body,
          mood: _moodIndex + 1,
          tags: _tags.toList(growable: false),
        );
      } else {
        await repository.createJournalEntry(
          title: _titleController.text.trim(),
          body: body,
          mood: _moodIndex + 1,
          tags: _tags.toList(growable: false),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.journalSaveError.tr(context: context),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocaleKeys.journalDeleteConfirmTitle.tr(context: context),
        ),
        content:
            Text(LocaleKeys.journalDeleteConfirmBody.tr(context: context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocaleKeys.cancel.tr(context: context)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LocaleKeys.deleteEntry.tr(context: context)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await getIt<EtzanBackendRepository>()
          .deleteJournalEntry(widget.entry!.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.journalDeleteError.tr(context: context)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleTag(String value) {
    setState(() {
      if (_tags.contains(value)) {
        _tags.remove(value);
      } else {
        _tags.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: _isEditing
          ? LocaleKeys.editEntry.tr(context: context)
          : LocaleKeys.newEntry.tr(context: context),
      actions: [
        if (_isEditing)
          IconButton(
            tooltip: LocaleKeys.deleteEntry.tr(context: context),
            onPressed: _saving ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.danger,
          ),
      ],
      child: ListView(
        children: [
          EtzanSectionTitle(
            title: LocaleKeys.moodQuestion.tr(context: context),
          ),
          const SizedBox(height: AppSpacing.sm),
          JournalMoodSelector(
            selectedIndex: _moodIndex,
            onChanged: (index) => setState(() => _moodIndex = index),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: LocaleKeys.journalTitleOptional.tr(context: context),
              hintText: LocaleKeys.journalTitleHint.tr(context: context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _bodyController,
            minLines: 9,
            maxLines: 14,
            decoration: InputDecoration(
              labelText: LocaleKeys.writeThoughts.tr(context: context),
              hintText: LocaleKeys.journalBodyHint.tr(context: context),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EtzanSectionTitle(
            title: LocaleKeys.addFeelingOrTag.tr(context: context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: journalTagOptions.map((option) {
              return EtzanTag(
                label: option.labelKey.tr(context: context),
                selected: _tags.contains(option.value),
                onTap: () => _toggleTag(option.value),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.xl),
          EtzanPrimaryButton(
            label: _saving
                ? LocaleKeys.saving.tr(context: context)
                : LocaleKeys.saveEntry.tr(context: context),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
