import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Clean brand header showcasing the MH SchoolOps Pro logo and institution title.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Logo from assets/branding/
        Container(
          height: 84,
          padding: const EdgeInsets.all(AppDimensions.space8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/branding/app_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.school_rounded,
              size: 48,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space20),

        // App Title
        Text(
          'SchoolOps Pro',
          style: AppTextStyles.displayMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space6),

        // Tagline badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: AppDimensions.space4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(
            'Institutional Management Platform',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
