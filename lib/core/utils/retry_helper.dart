import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../exceptions/app_exception.dart';

/// Configuration untuk retry mechanism
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
  });

  static const RetryConfig defaultConfig = RetryConfig();
  static const RetryConfig quickRetry = RetryConfig(
    maxAttempts = 2,
    initialDelay = Duration(milliseconds: 500),
  );
  static const RetryConfig aggressiveRetry = RetryConfig(
    maxAttempts = 5,
    initialDelay = Duration(milliseconds: 500),
    maxDelay = Duration(seconds: 30),
  );
}

/// Helper class untuk retry operations dengan exponential backoff
class RetryHelper {
  /// Execute operation dengan retry logic
  static Future<T> execute<T>({
    required Future<T> Function() operation,
    RetryConfig config = RetryConfig.defaultConfig,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      attempt++;

      try {
        return await operation();
      } catch (error) {
        // Cek apakah sudah mencapai max attempts
        if (attempt >= config.maxAttempts) {
          rethrow;
        }

        // Cek apakah error ini perlu di-retry
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        // Default: retry hanya untuk network errors
        if (shouldRetry == null && !_shouldRetryError(error)) {
          rethrow;
        }

        // Wait sebelum retry dengan exponential backoff
        await Future.delayed(delay);

        // Calculate next delay dengan backoff
        delay = Duration(
          milliseconds: (delay.inMilliseconds * config.backoffMultiplier).toInt(),
        );

        // Cap delay ke max delay
        if (delay > config.maxDelay) {
          delay = config.maxDelay;
        }
      }
    }
  }

  /// Execute operation dengan retry dan return Either result
  static Future<Result<T>> executeWithResult<T>({
    required Future<T> Function() operation,
    RetryConfig config = RetryConfig.defaultConfig,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    try {
      final result = await execute(
        operation: operation,
        config: config,
        shouldRetry: shouldRetry,
      );
      return Result.success(result);
    } catch (error) {
      return Result.failure(error);
    }
  }

  /// Cek apakah error perlu di-retry
  static bool _shouldRetryError(dynamic error) {
    // Network errors
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is NetworkException) return true;

    // Firestore errors yang bisa di-retry
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
        case 'network-request-failed':
          return true;
        default:
          return false;
      }
    }

    return false;
  }

  /// Execute dengan timeout
  static Future<T> executeWithTimeout<T>({
    required Future<T> Function() operation,
    Duration timeout = const Duration(seconds: 30),
    RetryConfig? retryConfig,
  }) async {
    if (retryConfig != null) {
      return await execute(
        operation: () => operation().timeout(timeout),
        config: retryConfig,
      );
    }

    return await operation().timeout(
      timeout,
      onTimeout: () {
        throw NetworkException.timeout();
      },
    );
  }
}

/// Result class untuk handle success/failure
class Result<T> {
  final T? data;
  final dynamic error;
  final bool isSuccess;

  const Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  factory Result.failure(dynamic error) {
    return Result._(error: error, isSuccess: false);
  }

  bool get isFailure => !isSuccess;

  /// Get data atau throw error jika failure
  T getOrThrow() {
    if (isSuccess) {
      return data as T;
    }
    throw error;
  }

  /// Get data atau return default value
  T getOrElse(T defaultValue) {
    return isSuccess ? (data as T) : defaultValue;
  }

  /// Get data atau return null
  T? getOrNull() {
    return isSuccess ? data : null;
  }

  /// Transform data jika success
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        return Result.success(transform(data as T));
      } catch (e) {
        return Result.failure(e);
      }
    }
    return Result.failure(error);
  }

  /// Execute callback berdasarkan hasil
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(dynamic error) onFailure,
  }) {
    return isSuccess ? onSuccess(data as T) : onFailure(error);
  }
}
