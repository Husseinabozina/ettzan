import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';

class EditProfileNameDialog extends StatefulWidget {
  const EditProfileNameDialog({required this.initialName, super.key});

  final String initialName;

  @override
  State<EditProfileNameDialog> createState() => _EditProfileNameDialogState();
}

class _EditProfileNameDialogState extends State<EditProfileNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit([String? value]) {
    Navigator.of(context).pop(value ?? _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.editName.tr(context: context)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: LocaleKeys.fullName.tr(context: context),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: _submit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.cancel.tr(context: context)),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(LocaleKeys.save.tr(context: context)),
        ),
      ],
    );
  }
}
