import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../authentication/presentation/state/auth_state.dart';
import '../widgets/module_card.dart';

/// Staff & Teacher Master Template Dashboard featuring 5 core management modules.
class StaffDashboardPage extends ConsumerWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = (authState is Authenticated) ? authState.profile.userName : 'Faculty';
    final userRole = (authState is Authenticated && authState.profile.roles.isNotEmpty)
        ? authState.profile.roles.first
        : 'Teacher';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Institution Branding and Logout
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            title: Row(
              children: [
                Image.asset(
                  'assets/branding/app_logo.png',
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school_rounded,
                    color: AppColors.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SchoolOps Pro',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Staff & Faculty Portal',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 22),
                tooltip: 'Sign Out',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(authStateProvider.notifier).logout();
                },
              ),
              const SizedBox(width: AppDimensions.space8),
            ],
          ),

          // Main Teacher Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppDimensions.space8),

                // Faculty Profile Card
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radius20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.3),
                        child: Text(
                          userName.isNotEmpty ? userName[0] : 'T',
                          style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userName,
                              style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppDimensions.space2),
                            Text(
                              '$userRole • Active Academic Session',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                // Section Title
                Text(
                  'Management Modules',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
              ]),
            ),
          ),

          // 5 Core Management Modules Grid (Teacher Landing Page)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppDimensions.space16,
                crossAxisSpacing: AppDimensions.space16,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildListDelegate([
                // 1. Messaging
                ModuleCard(
                  title: 'Messaging',
                  subtitle: 'Announcements & Chat',
                  icon: Icons.chat_bubble_outline_rounded,
                  accentColor: AppColors.moduleMessaging,
                  badgeText: 'Broadcast',
                  onTap: () {},
                ),

                // 2. Attendance
                ModuleCard(
                  title: 'Attendance',
                  subtitle: 'Mark Class Register',
                  icon: Icons.event_available_rounded,
                  accentColor: AppColors.moduleAttendance,
                  badgeText: 'Mark Today',
                  onTap: () {},
                ),

                // 3. Homework
                ModuleCard(
                  title: 'Homework',
                  subtitle: 'Assign & Review',
                  icon: Icons.menu_book_rounded,
                  accentColor: AppColors.moduleHomework,
                  badgeText: 'Create',
                  onTap: () {},
                ),

                // 4. Examination
                ModuleCard(
                  title: 'Examination',
                  subtitle: 'Enter Marks & Grades',
                  icon: Icons.assignment_outlined,
                  accentColor: AppColors.moduleExamination,
                  badgeText: 'Grading',
                  onTap: () {},
                ),

                // 5. Fee
                ModuleCard(
                  title: 'Fee',
                  subtitle: 'Fee Records & Status',
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: AppColors.moduleFee,
                  badgeText: 'Defaulters',
                  onTap: () {},
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.space40),
          ),
        ],
      ),
    );
  }
}
