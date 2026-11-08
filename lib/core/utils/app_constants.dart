abstract class AppConstants {
  // Roles
  static const String roleManager = 'manager';
  static const String roleEmployee = 'employee';

  // Adherence Tolerance in Minutes
  static const int defaultAdherenceToleranceMinutes = 2;

  // Request Types
  static const String requestLate = 'Two-Hour Late';
  static const String requestPto = 'PTO';
  static const String requestEarlyLeave = 'Early Leave';
  static const String requestOvertime = 'Overtime';
  static const String requestVgh = 'VGH'; // Voluntarily Gone Home

  static const List<String> requestTypes = [
    requestLate,
    requestPto,
    requestEarlyLeave,
    requestOvertime,
    requestVgh,
  ];

  // Request Statuses
  static const String statusPending = 'Pending';
  static const String statusApproved = 'Approved';
  static const String statusRejected = 'Rejected';
  static const String statusCancelled = 'Cancelled';

  // Adherence Statuses
  static const String adherenceOnTime = 'On-Time';
  static const String adherenceLate = 'Late';
  static const String adherenceEarly = 'Early';
  static const String adherenceUnplanned = 'Unplanned';

  // Firestore Collections
  static const String collectionUsers = 'users';
  static const String collectionCompanies = 'companies';
  static const String collectionDepartments = 'departments';
  static const String collectionActivities = 'activity_definitions';
  static const String collectionSchedules = 'planned_schedules';
  static const String collectionActivityTransitions = 'actual_activity_transitions';
  static const String collectionAttendance = 'attendance_records';
  static const String collectionRequests = 'requests';
  static const String collectionNotifications = 'notifications';
}
