/// Named route constants for GoRouter.
class RouteConstants {
  const RouteConstants._();

  // Authentication
  static const String login = '/login';
  static const String loginName = 'login';

  // Student / Parent Dashboard
  static const String studentDashboard = '/student/dashboard';
  static const String studentDashboardName = 'student_dashboard';

  // Staff / Teacher Dashboard
  static const String staffDashboard = '/staff/dashboard';
  static const String staffDashboardName = 'staff_dashboard';

  // Feature Modules (Student/Parent)
  static const String studentMessaging = '/student/messaging';
  static const String studentAttendance = '/student/attendance';
  static const String studentHomework = '/student/homework';
  static const String studentExamination = '/student/examination';
  static const String studentFee = '/student/fee';
  static const String studentClassTest = '/student/class-test';
  static const String studentActivityPlanner = '/student/activity-planner';
  static const String studentTransport = '/student/transport';

  // Feature Modules (Staff/Teacher)
  static const String staffMessaging = '/staff/messaging';
  static const String staffAttendance = '/staff/attendance';
  static const String staffHomework = '/staff/homework';
  static const String staffExamination = '/staff/examination';
  static const String staffFee = '/staff/fee';
}
