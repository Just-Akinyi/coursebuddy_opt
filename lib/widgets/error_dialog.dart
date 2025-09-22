// Displays a robust error dialog with options to retry, dismiss, and view details.
// Logs error to Firebase Crashlytics and presents a user-friendly dialog.
// Optionally accepts a retry callback to allow the user to retry the failed action.

import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:coursebuddy/widgets/shared_button.dart';

typedef RetryCallback = Future<void> Function();

Future<void> showError(
  BuildContext context,
  Object error, {
  StackTrace? stackTrace,
  String title = "Oops!",
  String? userMessage,
  RetryCallback? onRetry,
}) async {
  // Log to Crashlytics
  try {
    await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  } catch (_) {
    // Fail silently if Crashlytics not available
  }

  final errorMessage =
      userMessage ?? error.toString().replaceFirst('Exception: ', '');

  if (!context.mounted) return;

  bool detailsExpanded = false;

  await showDialog(
    context: context,
    barrierDismissible: false, // force user interaction to dismiss
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                if (stackTrace != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        setState(() => detailsExpanded = !detailsExpanded),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          detailsExpanded ? "Hide Details" : "Show Details",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          detailsExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  if (detailsExpanded)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Text(
                          stackTrace.toString(),
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            if (onRetry != null)
              SharedButton(
                icon: Icons.refresh,
                label: "Retry",
                onPressed: () async {
                  Navigator.of(context).pop();
                  await onRetry();
                },
              ),
            SharedButton(
              icon: Icons.close,
              label: "Dismiss",
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      });
    },
  );
}
