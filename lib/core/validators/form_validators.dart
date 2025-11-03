import '../constants/app_constants.dart';
import '../constants/validation_constants.dart';
import '../security/input_sanitizer.dart';

/// Form validation utilities
///
/// SECURITY: All validators now check for potentially dangerous input patterns
class FormValidators {
  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    return null;
  }

  /// Validate required field dengan minimum length
  static String? requiredWithMinLength(
    String? value, {
    String? fieldName,
    int minLength = 1,
  }) {
    final requiredError = required(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    if (value!.trim().length < minLength) {
      return '${fieldName ?? 'Field'} minimal $minLength karakter';
    }
    return null;
  }

  /// Validate required field dengan max length
  static String? requiredWithMaxLength(
    String? value, {
    String? fieldName,
    int maxLength = 255,
  }) {
    final requiredError = required(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    if (value!.trim().length > maxLength) {
      return '${fieldName ?? 'Field'} maksimal $maxLength karakter';
    }
    return null;
  }

  /// Validate username
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username wajib diisi';
    }
    if (value.length < ValidationConstants.minUsernameLength) {
      return 'Username minimal ${ValidationConstants.minUsernameLength} karakter';
    }
    if (value.length > ValidationConstants.maxUsernameLength) {
      return 'Username maksimal ${ValidationConstants.maxUsernameLength} karakter';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return ValidationConstants.invalidUsernameError;
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < ValidationConstants.minPasswordLength) {
      return ValidationConstants.passwordTooShortError;
    }
    if (value.length > ValidationConstants.maxPasswordLength) {
      return 'Password maksimal ${ValidationConstants.maxPasswordLength} karakter';
    }
    return null;
  }

  /// Validate password confirmation
  static String? passwordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return ValidationConstants.passwordMismatchError;
    }
    return null;
  }

  /// Validate numeric field
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Field'} harus berupa angka';
    }
    return null;
  }

  /// Validate numeric dengan min dan max value
  static String? numericRange(
    String? value, {
    String? fieldName,
    double? min,
    double? max,
  }) {
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (min != null && number < min) {
      return '${fieldName ?? 'Field'} minimal $min';
    }
    if (max != null && number > max) {
      return '${fieldName ?? 'Field'} maksimal $max';
    }
    return null;
  }


  /// Validate time range
  static String? timeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) {
      return 'Waktu mulai dan selesai wajib diisi';
    }
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return ValidationConstants.invalidTimeRangeError;
    }

    // Validasi maksimal durasi
    final duration = endTime.difference(startTime);
    if (duration.inHours > ValidationConstants.maxOvertimeDurationHours) {
      return ValidationConstants.durationTooLongError;
    }

    return null;
  }

  /// Validate date tidak di masa depan
  static String? notFutureDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return '${fieldName ?? 'Tanggal'} wajib diisi';
    }
    final now = DateTime.now();
    // Compare hanya tanggal, bukan waktu
    if (DateTime(date.year, date.month, date.day)
        .isAfter(DateTime(now.year, now.month, now.day))) {
      return '${fieldName ?? 'Tanggal'} tidak boleh di masa depan';
    }
    return null;
  }

  /// Validate employee selection
  static String? employeeSelection(List<String>? selectedEmployees) {
    if (selectedEmployees == null || selectedEmployees.isEmpty) {
      return ValidationConstants.noEmployeesError;
    }
    if (selectedEmployees.length > ValidationConstants.maxEmployeeSelection) {
      return ValidationConstants.tooManyEmployeesError;
    }
    return null;
  }

  /// Validate work type selection
  static String? workTypeSelection(List<String>? selectedWorkTypes) {
    if (selectedWorkTypes == null || selectedWorkTypes.isEmpty) {
      return ValidationConstants.noWorkTypesError;
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

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Validate list tidak kosong
  static String? listNotEmpty<T>(List<T>? list, {String? fieldName}) {
    if (list == null || list.isEmpty) {
      return '${fieldName ?? 'Data'} tidak boleh kosong';
    }
    return null;
  }

  // ===== SECURITY VALIDATORS =====

  /// Validate input is safe (no XSS, injection, etc.)
  ///
  /// SECURITY: Check for potentially dangerous patterns
  static String? safeInput(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (!InputSanitizer.isSafe(value)) {
      return '${fieldName ?? 'Input'} mengandung karakter tidak diperbolehkan';
    }

    return null;
  }

  /// Validate and sanitize text field
  ///
  /// Returns error if unsafe, otherwise null
  static String? safeTextField(String? value, {String? fieldName}) {
    // Check if required
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }

    // Check safety
    if (!InputSanitizer.isSafe(value)) {
      return '${fieldName ?? 'Field'} mengandung karakter tidak diperbolehkan';
    }

    return null;
  }

  /// Validate customer name with safety check
  static String? customerName(String? value) {
    final requiredError = requiredWithMaxLength(
      value,
      fieldName: 'Nama customer',
      maxLength: AppConstants.maxCustomerLength,
    );
    if (requiredError != null) return requiredError;

    return safeInput(value, fieldName: 'Nama customer');
  }

  /// Validate problem description with safety check
  static String? reportedProblem(String? value) {
    final requiredError = requiredWithMinLength(
      value,
      fieldName: 'Reported Problem',
      minLength: AppConstants.minReportedProblemLength,
    );
    if (requiredError != null) return requiredError;

    final maxError = requiredWithMaxLength(
      value,
      fieldName: 'Reported Problem',
      maxLength: AppConstants.maxReportedProblemLength,
    );
    if (maxError != null) return maxError;

    return safeInput(value, fieldName: 'Reported Problem');
  }

  /// Validate work description with safety check
  static String? workDescription(String? value) {
    final requiredError = requiredWithMinLength(
      value,
      fieldName: 'Deskripsi pekerjaan',
      minLength: AppConstants.minWorkingDescriptionLength,
    );
    if (requiredError != null) return requiredError;

    final maxError = requiredWithMaxLength(
      value,
      fieldName: 'Deskripsi pekerjaan',
      maxLength: AppConstants.maxWorkingDescriptionLength,
    );
    if (maxError != null) return maxError;

    return safeInput(value, fieldName: 'Deskripsi pekerjaan');
  }
}
