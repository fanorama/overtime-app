/// Base exception class untuk aplikasi
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Exception untuk masalah jaringan
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'Tidak ada koneksi internet. Periksa koneksi Anda.',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Permintaan timeout. Coba lagi.',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.serverError() {
    return const NetworkException(
      message: 'Server sedang bermasalah. Coba beberapa saat lagi.',
      code: 'SERVER_ERROR',
    );
  }
}

/// Exception untuk authentication
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: 'Username atau password salah.',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthException.userNotFound() {
    return const AuthException(
      message: 'User tidak ditemukan.',
      code: 'USER_NOT_FOUND',
    );
  }

  factory AuthException.emailAlreadyInUse() {
    return const AuthException(
      message: 'Username sudah digunakan.',
      code: 'EMAIL_ALREADY_IN_USE',
    );
  }

  factory AuthException.weakPassword() {
    return const AuthException(
      message: 'Password terlalu lemah. Minimal 6 karakter.',
      code: 'WEAK_PASSWORD',
    );
  }

  factory AuthException.unauthorized() {
    return const AuthException(
      message: 'Anda tidak memiliki akses untuk melakukan aksi ini.',
      code: 'UNAUTHORIZED',
    );
  }

  factory AuthException.sessionExpired() {
    return const AuthException(
      message: 'Sesi Anda telah berakhir. Silakan login kembali.',
      code: 'SESSION_EXPIRED',
    );
  }
}

/// Exception untuk data validation
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  factory ValidationException.requiredField(String fieldName) {
    return ValidationException(
      message: '$fieldName wajib diisi.',
      code: 'REQUIRED_FIELD',
      fieldErrors: {fieldName: 'Field wajib diisi'},
    );
  }

  factory ValidationException.invalidFormat(String fieldName) {
    return ValidationException(
      message: 'Format $fieldName tidak valid.',
      code: 'INVALID_FORMAT',
      fieldErrors: {fieldName: 'Format tidak valid'},
    );
  }

  factory ValidationException.multipleErrors(Map<String, String> errors) {
    return ValidationException(
      message: 'Beberapa field tidak valid.',
      code: 'MULTIPLE_ERRORS',
      fieldErrors: errors,
    );
  }
}

/// Exception untuk data tidak ditemukan
class DataNotFoundException extends AppException {
  const DataNotFoundException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory DataNotFoundException.employee() {
    return const DataNotFoundException(
      message: 'Data karyawan tidak ditemukan.',
      code: 'EMPLOYEE_NOT_FOUND',
    );
  }

  factory DataNotFoundException.overtimeRequest() {
    return const DataNotFoundException(
      message: 'Data lembur tidak ditemukan.',
      code: 'OVERTIME_NOT_FOUND',
    );
  }

  factory DataNotFoundException.generic(String entityName) {
    return DataNotFoundException(
      message: '$entityName tidak ditemukan.',
      code: 'NOT_FOUND',
    );
  }
}

/// Exception untuk operasi yang tidak diizinkan
class OperationNotAllowedException extends AppException {
  const OperationNotAllowedException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory OperationNotAllowedException.editApproved() {
    return const OperationNotAllowedException(
      message: 'Tidak dapat mengedit data yang sudah disetujui tanpa konfirmasi.',
      code: 'EDIT_APPROVED',
    );
  }

  factory OperationNotAllowedException.deleteApproved() {
    return const OperationNotAllowedException(
      message: 'Tidak dapat menghapus data yang sudah disetujui.',
      code: 'DELETE_APPROVED',
    );
  }

  factory OperationNotAllowedException.unauthorized() {
    return const OperationNotAllowedException(
      message: 'Anda tidak memiliki izin untuk melakukan operasi ini.',
      code: 'UNAUTHORIZED',
    );
  }
}

/// Exception untuk Firestore
class FirestoreException extends AppException {
  const FirestoreException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory FirestoreException.permissionDenied() {
    return const FirestoreException(
      message: 'Akses ditolak. Anda tidak memiliki izin.',
      code: 'PERMISSION_DENIED',
    );
  }

  factory FirestoreException.unavailable() {
    return const FirestoreException(
      message: 'Database tidak tersedia. Coba lagi nanti.',
      code: 'UNAVAILABLE',
    );
  }

  factory FirestoreException.alreadyExists() {
    return const FirestoreException(
      message: 'Data sudah ada.',
      code: 'ALREADY_EXISTS',
    );
  }
}

/// Exception untuk error yang tidak diketahui atau tidak terdefinisi
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory UnknownException.fromError(dynamic error) {
    return UnknownException(
      message: 'Terjadi kesalahan yang tidak diketahui: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: error,
    );
  }
}
