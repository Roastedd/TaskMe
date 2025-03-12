import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final bool useScaffold;
  final Color? backgroundColor;
  final Widget? customIllustration;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subMessage,
    required this.icon,
    this.onActionPressed,
    this.actionLabel,
    this.useScaffold = false,
    this.backgroundColor,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: AppStyles.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIllustration != null)
              customIllustration!
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                  )
                  .fadeIn(duration: 400.ms)
            else
              Icon(
                icon,
                size: 64,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withAlpha(128),
              )
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                  )
                  .fadeIn(duration: 400.ms),
            const SizedBox(height: AppStyles.spacing24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.color
                        ?.withAlpha(204),
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ),
            if (subMessage != null) ...[
              const SizedBox(height: AppStyles.spacing8),
              Text(
                subMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(153),
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                    duration: 400.ms,
                    delay: 300.ms,
                  ),
            ],
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: AppStyles.spacing24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: AppStyles.buttonPadding,
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: 400.ms,
                  )
                  .scale(
                    duration: 600.ms,
                    delay: 400.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                  ),
            ],
          ],
        ),
      ),
    );

    if (useScaffold) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: content,
      );
    }

    return content;
  }
}
