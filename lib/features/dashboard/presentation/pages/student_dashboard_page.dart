import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../authentication/presentation/state/auth_state.dart';
import '../../../student/presentation/providers/sibling_notifier.dart';
import '../../../student/presentation/widgets/sibling_selector_modal.dart';
import '../widgets/module_card.dart';

/// Student & Parent Master Template Dashboard featuring 8 core action modules
/// and reactive Multi-Sibling Profile Switcher.
class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final activeSibling = ref.watch(activeSiblingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = (authState is Authenticated) ? authState.profile.userName : 'Parent';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Institution Branding and Logout
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
                      'Student & Parent Portal',
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

          // Main Dashboard Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppDimensions.space8),

                // Multi-Sibling Switcher Header Card
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryNavy, AppColors.primaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radius20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          (activeSibling?.fullName.isNotEmpty ?? false)
                              ? activeSibling!.fullName[0]
                              : 'S',
                          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  activeSibling?.fullName ?? 'Student Profile',
                                  style: AppTextStyles.headingMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.space2),
                            Text(
                              activeSibling != null
                                  ? '${activeSibling.classSection} • Roll #${activeSibling.rollNumber}'
                                  : 'Active Student',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sibling Switch Button
                      Material(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          onTap: () => SiblingSelectorModal.show(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  'Switch',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                // Greeting & Module Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Academic Overview',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Welcome, $userName',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),
              ]),
            ),
          ),

          // 8 Interactive Module Cards Grid (Student/Parent Landing Page)
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
                  subtitle: 'Chat & Notices',
                  icon: Icons.chat_bubble_outline_rounded,
                  accentColor: AppColors.moduleMessaging,
                  badgeText: '2 New',
                  onTap: () {},
                ),

                // 2. Attendance
                ModuleCard(
                  title: 'Attendance',
                  subtitle: 'Term Summary',
                  icon: Icons.event_available_rounded,
                  accentColor: AppColors.moduleAttendance,
                  badgeText: '96.2%',
                  onTap: () {},
                ),

                // 3. Homework
                ModuleCard(
                  title: 'Homework',
                  subtitle: 'Daily Tasks',
                  icon: Icons.menu_book_rounded,
                  accentColor: AppColors.moduleHomework,
                  badgeText: '3 Due',
                  onTap: () {},
                ),

                // 4. Examination
                ModuleCard(
                  title: 'Examination',
                  subtitle: 'Schedules & Marks',
                  icon: Icons.assignment_outlined,
                  accentColor: AppColors.moduleExamination,
                  badgeText: 'Term 1',
                  onTap: () {},
                ),

                // 5. Fee
                ModuleCard(
                  title: 'Fee',
                  subtitle: 'Receipts & Due',
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: AppColors.moduleFee,
                  badgeText: 'Paid',
                  onTap: () {},
                ),

                // 6. Class Test
                ModuleCard(
                  title: 'Class Test',
                  subtitle: 'Weekly Assessments',
                  icon: Icons.timer_outlined,
                  accentColor: AppColors.moduleClassTest,
                  badgeText: '88 Avg',
                  onTap: () {},
                ),

                // 7. Activity Planner
                ModuleCard(
                  title: 'Activity Planner',
                  subtitle: 'Events & Holidays',
                  icon: Icons.calendar_month_outlined,
                  accentColor: AppColors.moduleActivity,
                  badgeText: 'Oct',
                  onTap: () {},
                ),

                // 8. Transport
                ModuleCard(
                  title: 'Transport',
                  subtitle: 'Route & Bus Tracking',
                  icon: Icons.directions_bus_outlined,
                  accentColor: AppColors.moduleTransport,
                  badgeText: 'Route 14',
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
