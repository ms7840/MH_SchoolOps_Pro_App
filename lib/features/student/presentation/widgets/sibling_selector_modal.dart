import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/message_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/sibling_notifier.dart';

/// Modern bottom sheet for parents to switch between children profiles.
class SiblingSelectorModal extends ConsumerWidget {
  const SiblingSelectorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SiblingSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siblingState = ref.watch(siblingNotifierProvider);
    final activeSibling = siblingState.activeSibling;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radius24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space20,
        AppDimensions.space12,
        AppDimensions.space20,
        AppDimensions.space32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppDimensions.space16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          ),

          // Title
          Text(
            MessageConstants.switchChild,
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(
            MessageConstants.selectChildPrompt,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Sibling List
          ...siblingState.siblings.map((sibling) {
            final isSelected = sibling.studentId == activeSibling?.studentId;

            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.space12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? AppColors.primaryBlue.withOpacity(0.15)
                        : AppColors.primaryBlue.withOpacity(0.06))
                    : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space4,
                ),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: isSelected ? AppColors.primaryBlue : AppColors.primaryNavy,
                  child: Text(
                    sibling.fullName.isNotEmpty ? sibling.fullName[0] : 'S',
                    style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                  ),
                ),
                title: Text(
                  sibling.fullName,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  '${sibling.classSection} • ${sibling.admissionNumber}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                        size: 24,
                      )
                    : null,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(siblingNotifierProvider.notifier).switchSibling(sibling.studentId);
                  Navigator.of(context).pop();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
