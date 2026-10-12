import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

/// Enterprise production-ready button widget with variant styles and loading state.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width = double.infinity,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primaryBlue;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
        foregroundColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primaryBlue;
        borderSide = const BorderSide(color: AppColors.primaryBlue, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
    }

    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
          boxShadow: (variant == AppButtonVariant.primary && isEnabled)
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: backgroundColor.withOpacity(0.5),
            disabledForegroundColor: foregroundColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              side: borderSide,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: AppDimensions.space8),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.button.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
