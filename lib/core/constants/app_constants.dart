/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Overtime Management';
  static const String appVersion = '1.0.0';

  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String employeesCollection = 'employees';
  static const String overtimeRequestsCollection = 'overtime_requests';

  // User Roles
  static const String roleEmployee = 'employee';
  static const String roleManager = 'manager';

  // Overtime Status
  static const String statusPending = 'PENDING';
  static const String statusApproved = 'APPROVED';
  static const String statusRejected = 'REJECTED';

  // Work Types
  static const String workTypeInstallation = 'Installation';
  static const String workTypeRepair = 'Repair';
  static const String workTypePreventive = 'Preventive';
  static const String workTypeMonitoring = 'Monitoring';
  static const String workTypeOther = 'Other';

  // Severity Levels
  static const String severityLow = 'Low';
  static const String severityMedium = 'Medium';
  static const String severityHigh = 'High';
  static const String severityCritical = 'Critical';

  // Earning Rates (Phase 1: Hardcoded)
  static const double baseWeekdayRate = 50000; // per hour
  static const double baseWeekendRate = 75000; // per hour
  static const double mealAllowance = 25000; // per day

  // Work Type Multipliers
  static const Map<String, double> workTypeMultipliers = {
    workTypeInstallation: 1.2,
    workTypeRepair: 1.5,
    workTypePreventive: 1.0,
    workTypeMonitoring: 1.0,
    workTypeOther: 1.0,
  };

  // Form Validation
  static const int maxCustomerNameLength = 100;
  static const int maxProblemDescriptionLength = 500;
  static const int maxLocationLength = 200;
  static const int maxNotesLength = 1000;
  static const int minEmployeeSelection = 1;

  // Performance
  static const int dashboardQueryLimit = 100;
  static const Duration cacheExpiration = Duration(hours: 1);

  // Date Format
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
}
