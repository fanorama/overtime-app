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
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    if (value.length > 20) {
      return 'Username maksimal 20 karakter';
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
    if (value.length > 50) {
      return 'Password maksimal 50 karakter';
    }
    return null;
  }

  /// Validate password confirmation
  static String? passwordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak cocok';
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
      return 'Waktu selesai harus lebih besar dari waktu mulai';
    }

    // Validasi maksimal durasi (misal 24 jam)
    final duration = endTime.difference(startTime);
    if (duration.inHours > 24) {
      return 'Durasi lembur tidak boleh lebih dari 24 jam';
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
      return 'Minimal pilih ${AppConstants.minEmployeeSelection} karyawan';
    }
    if (selectedEmployees.length > 50) {
      return 'Maksimal pilih 50 karyawan';
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
}
