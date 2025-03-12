import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/styles.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool useScaffold;
  final Color? backgroundColor;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.useScaffold = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator()
              .animate()
              .scale(
                duration: 600.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
              )
              .fadeIn(duration: 400.ms),
          if (message != null) ...[
            const SizedBox(height: AppStyles.spacing16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(179),
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                ),
          ],
        ],
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