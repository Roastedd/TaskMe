import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme_config.dart';
import '../config/styles.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? technicalDetails;
  final VoidCallback? onRetry;
  final bool useScaffold;
  final Color? backgroundColor;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.technicalDetails,
    this.onRetry,
    this.useScaffold = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: AppStyles.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withAlpha(204),
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
            SelectableText.rich(
              TextSpan(
                text: message,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.error,
                    ),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ),
            if (technicalDetails != null) ...[
              const SizedBox(height: AppStyles.spacing16),
              SelectableText.rich(
                TextSpan(
                  text: technicalDetails!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha(179),
                        fontFamily: 'monospace',
                      ),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                    duration: 400.ms,
                    delay: 300.ms,
                  ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppStyles.spacing24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
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
