import '../constants/app_constants.dart';

/// Form validation utilities
class FormValidators {
  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    return null;
  }

  /// Validate username
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username wajib diisi';
    }
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username hanya boleh mengandung huruf, angka, dan underscore';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }


  /// Validate time range
  static String? timeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) {
      return 'Waktu mulai dan selesai wajib diisi';
    }
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return 'Waktu selesai harus lebih besar dari waktu mulai';
    }
    return null;
  }

  /// Validate employee selection
  static String? employeeSelection(List<String>? selectedEmployees) {
    if (selectedEmployees == null || selectedEmployees.isEmpty) {
      return 'Minimal pilih ${AppConstants.minEmployeeSelection} karyawan';
    }
    return null;
  }

  /// Validate work type selection
  static String? workTypeSelection(List<String>? selectedWorkTypes) {
    if (selectedWorkTypes == null || selectedWorkTypes.isEmpty) {
      return 'Minimal pilih 1 jenis pekerjaan';
    }
    return null;
  }

  /// Validate dropdown selection
  static String? dropdownSelection(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} wajib dipilih';
    }
    return null;
  }
}
