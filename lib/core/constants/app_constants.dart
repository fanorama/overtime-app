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
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Type of Work (as per design schema)
  static const String workTypeOvertime = 'Overtime';
  static const String workTypeCall = 'Call';
  static const String workTypeUnplanned = 'Unplanned';
  static const String workTypeNonOT = 'NonOT';
  static const String workTypeVisitSiang = 'Visit Siang';

  // Severity Levels
  static const String severityLow = 'low';
  static const String severityMedium = 'medium';
  static const String severityHigh = 'high';
  static const String severityCritical = 'critical';

  // Employee Roles
  static const String employeeRoleEngineer = 'engineer';
  static const String employeeRoleMaintenance = 'maintenance';
  static const String employeeRolePostsales = 'postsales';
  static const String employeeRoleOnsite = 'onsite';

  // Earning Rates (Phase 1: Hardcoded)
  static const double baseWeekdayRate = 50000; // per hour
  static const double baseWeekendRate = 75000; // per hour
  static const double mealAllowance = 25000; // per day

  // Work Type Multipliers (as per design schema)
  static const Map<String, double> workTypeMultipliers = {
    workTypeOvertime: 1.0,      // Base rate
    workTypeCall: 1.2,          // 20% extra
    workTypeUnplanned: 1.5,     // 50% extra
    workTypeNonOT: 0.5,         // Half rate
    workTypeVisitSiang: 1.0,    // Base rate
  };

  // Form Validation
  static const int maxCustomerLength = 100;
  static const int minReportedProblemLength = 10;
  static const int maxReportedProblemLength = 500;
  static const int minWorkingDescriptionLength = 10;
  static const int maxWorkingDescriptionLength = 1000;
  static const int maxProductLength = 100;
  static const int maxNextActivityLength = 500;
  static const int maxVersionLength = 50;
  static const int maxPicLength = 100;
  static const int minEmployeeSelection = 1;

  // Performance
  static const int dashboardQueryLimit = 100;
  static const Duration cacheExpiration = Duration(hours: 1);

  // Date Format
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
}
