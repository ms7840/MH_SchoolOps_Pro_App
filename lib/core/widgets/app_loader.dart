import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Centralized branded loader.
class AppLoader extends StatelessWidget {
  final String? message;
  final double size;

  const AppLoader({
    super.key,
    this.message,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryBlue,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.space16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
