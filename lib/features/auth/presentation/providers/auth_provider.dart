import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_state.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth controller for handling authentication actions
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState()) {
    _checkAuthState();
  }

  /// Check current authentication state
  Future<void> _checkAuthState() async {
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // Silently fail, user is not authenticated
      state = state.copyWith(user: null);
    }
  }

  /// Login with username and password
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.setLoading(true).clearError();

    try {
      final user = await _repository.login(
        username: username,
        password: password,
      );

      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Register new user
  Future<void> register({
    required String username,
    required String password,
    required String role,
    String? displayName,
  }) async {
    state = state.setLoading(true).clearError();

    try {
      final user = await _repository.register(
        username: username,
        password: password,
        role: role,
        displayName: displayName,
      );

      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.setLoading(true);

    try {
      await _repository.logout();
      state = const AuthState();
    } catch (e) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }
}

/// Auth controller provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

/// Current user provider (convenient getter)
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authControllerProvider).user;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});
