import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme_config.dart';
import '../config/styles.dart';

class CommonWidgets {
  static Widget buildAppBar({
    required String title,
    String? subtitle,
    List<Widget>? actions,
    bool centerTitle = true,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
    );
  }

  static Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    Color? color,
    double? elevation,
  }) {
    return Card(
      color: color,
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.borderRadius12,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.borderRadius12,
        child: Padding(
          padding: padding ?? AppStyles.cardPadding,
          child: child,
        ),
      ),
    );
  }

  static Widget buildShimmerLoadingCard({
    double height = 100,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      height: height,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.shimmerBaseLight,
        borderRadius: AppStyles.borderRadius12,
      ),
    );
  }

  static Widget buildFloatingActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }

  static Widget buildRefreshIndicator({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }

  static Widget buildAnimatedListItem({
    required Widget child,
    required int index,
    Duration? duration,
  }) {
    return AnimatedPadding(
      duration: duration ?? AppStyles.normalAnimationDuration,
      padding: EdgeInsets.only(
        top: index == 0 ? AppStyles.spacing16 : AppStyles.spacing8,
        left: AppStyles.spacing16,
        right: AppStyles.spacing16,
        bottom: AppStyles.spacing8,
      ),
      child: child,
    );
  }

  static Widget buildDivider({
    double height = 1,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      height: height,
      color: AppColors.dividerLight,
    );
  }

  static Widget buildSectionHeader({
    required String title,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacing16,
        vertical: AppStyles.spacing8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  static Widget buildEmptyListPlaceholder({
    required String message,
    required IconData icon,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: AppStyles.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppStyles.spacing16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: AppStyles.spacing24),
              OutlinedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildLoadingOverlay({
    required bool isLoading,
    required Widget child,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  static Widget buildErrorText(String message) {
    return SelectableText.rich(
      TextSpan(
        text: message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.error,
        ),
      ),
    );
  }
}
