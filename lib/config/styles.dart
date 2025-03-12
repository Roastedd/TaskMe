import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_config.dart';

class AppStyles {
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Padding
  static const cardPadding = EdgeInsets.all(spacing16);
  static const screenPadding = EdgeInsets.all(spacing16);
  static const listItemPadding = EdgeInsets.symmetric(
    horizontal: spacing16,
    vertical: spacing12,
  );
  static const buttonPadding = EdgeInsets.symmetric(
    horizontal: spacing24,
    vertical: spacing12,
  );

  // Border Radius
  static final borderRadius4 = BorderRadius.circular(4.0);
  static final borderRadius8 = BorderRadius.circular(8.0);
  static final borderRadius12 = BorderRadius.circular(12.0);
  static final borderRadius16 = BorderRadius.circular(16.0);
  static final borderRadius24 = BorderRadius.circular(24.0);
  static final borderRadius32 = BorderRadius.circular(32.0);

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Color(0x1AFFFFFF),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration normalAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Common Widget Styles
  static Widget buildEmptyState({
    required String message,
    required IconData icon,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: spacing16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: spacing24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: spacing16),
            SelectableText.rich(
              TextSpan(
                text: message,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.error,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spacing24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget buildSettingsItem({
    required String title,
    required IconData icon,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: trailing,
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  static Widget buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: spacing16,
            right: spacing16,
            top: spacing24,
            bottom: spacing8,
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: spacing16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
