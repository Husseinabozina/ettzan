import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

/// Shared error view for feature pages.
///
/// Feature pages pass localized values in; this widget deliberately owns no
/// user-facing copy so it remains reusable in Arabic and English.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EtzanEmptyState(
        title: title,
        body: message,
        action: EtzanPrimaryButton(label: retryLabel, onPressed: onRetry),
      );
}
