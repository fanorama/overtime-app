import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';

/// Authentication state
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  AuthState clearError() {
    return copyWith(error: null);
  }

  AuthState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }
}

/// Auth state provider
final authStateProvider = StateProvider<AuthState>((ref) {
  return const AuthState();
});
