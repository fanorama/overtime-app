/// Constants untuk validation rules
class ValidationConstants {
  // Employee Selection Limits
  static const int minEmployeeSelection = 1;
  static const int maxEmployeeSelection = 50;

  // Username Constraints
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  // Password Constraints
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // Time Range Constraints
  static const int maxOvertimeDurationHours = 24;

  // Rejection Reason Constraints
  static const int minRejectionReasonLength = 10;
  static const int maxRejectionReasonLength = 500;

  // Error Messages
  static const String requiredFieldError = 'Field wajib diisi';
  static const String invalidEmailError = 'Format email tidak valid';
  static const String invalidUsernameError =
      'Username hanya boleh mengandung huruf, angka, dan underscore';
  static const String passwordTooShortError = 'Password minimal 6 karakter';
  static const String passwordMismatchError = 'Password tidak cocok';
  static const String invalidTimeRangeError =
      'Waktu selesai harus lebih besar dari waktu mulai';
  static const String durationTooLongError =
      'Durasi lembur tidak boleh lebih dari 24 jam';
  static const String noEmployeesError = 'Minimal pilih 1 karyawan';
  static const String tooManyEmployeesError = 'Maksimal pilih 50 karyawan';
  static const String noWorkTypesError = 'Minimal pilih 1 jenis pekerjaan';

  // Numeric Validation
  static const double defaultEarnings = 0.0;
  static const double earningsComparisonTolerance = 0.01;

  // Severity Display
  static const Map<String, String> severityLabels = {
    'low': 'Rendah',
    'medium': 'Sedang',
    'high': 'Tinggi',
    'critical': 'Kritis',
  };

  // Status Display
  static const Map<String, String> statusLabels = {
    'pending': 'Menunggu',
    'approved': 'Disetujui',
    'rejected': 'Ditolak',
  };

  // Colors (Hex)
  static const Map<String, String> statusColors = {
    'pending': '#FFA726', // Orange
    'approved': '#66BB6A', // Green
    'rejected': '#EF5350', // Red
  };

  static const Map<String, String> severityColors = {
    'low': '#66BB6A', // Green
    'medium': '#FFA726', // Orange
    'high': '#FF7043', // Deep Orange
    'critical': '#EF5350', // Red
  };
}
