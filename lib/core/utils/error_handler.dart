import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../exceptions/app_exception.dart';

/// Utility class untuk handle error dari berbagai sumber
class ErrorHandler {
  /// Convert Firebase Auth error ke AppException
  static AppException handleFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException.invalidCredentials();
      case 'email-already-in-use':
        return AuthException.emailAlreadyInUse();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'user-disabled':
        return const AuthException(
          message: 'Akun Anda telah dinonaktifkan.',
          code: 'USER_DISABLED',
        );
      case 'too-many-requests':
        return const AuthException(
          message: 'Terlalu banyak percobaan. Coba lagi nanti.',
          code: 'TOO_MANY_REQUESTS',
        );
      case 'network-request-failed':
        return NetworkException.noConnection();
      default:
        return AuthException(
          message: 'Terjadi kesalahan: ${error.message}',
          code: error.code,
          originalError: error,
        );
    }
  }

  /// Convert Firestore error ke AppException
  static AppException handleFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return FirestoreException.permissionDenied();
      case 'unavailable':
        return FirestoreException.unavailable();
      case 'already-exists':
        return FirestoreException.alreadyExists();
      case 'not-found':
        return const DataNotFoundException(
          message: 'Data tidak ditemukan.',
          code: 'NOT_FOUND',
        );
      case 'deadline-exceeded':
        return NetworkException.timeout();
      case 'network-request-failed':
        return NetworkException.noConnection();
      default:
        return FirestoreException(
          message: 'Terjadi kesalahan database: ${error.message}',
          code: error.code,
          originalError: error,
        );
    }
  }

  /// Convert generic error ke AppException
  static AppException handleGenericError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return handleFirebaseAuthError(error);
    }

    if (error is FirebaseException) {
      return handleFirestoreError(error);
    }

    // Default error
    return AppException(
      message: 'Terjadi kesalahan yang tidak diketahui: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: error,
    );
  }

  /// Get user-friendly error message
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is FirebaseAuthException) {
      return handleFirebaseAuthError(error).message;
    }

    if (error is FirebaseException) {
      return handleFirestoreError(error).message;
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
