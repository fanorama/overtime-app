import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/retry_helper.dart';

/// Authentication repository
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get current user stream
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (!doc.exists) return null;

        return UserModel.fromFirestore(doc).toEntity();
      } catch (e) {
        return null;
      }
    });
  }

  /// Login with username and password
  ///
  /// Firebase Auth uses email, so we map username to {username}@overtime.internal
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      return await RetryHelper.execute(
        operation: () async {
          // Convert username to email format for Firebase
          final email = '$username@overtime.internal';

          // Sign in with Firebase Auth
          final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (credential.user == null) {
            throw AuthException.invalidCredentials();
          }

          // Get user data from Firestore dengan retry
          final doc = await _firestore
              .collection(AppConstants.usersCollection)
              .doc(credential.user!.uid)
              .get();

          if (!doc.exists) {
            throw AuthException.userNotFound();
          }

          return UserModel.fromFirestore(doc).toEntity();
        },
        config: RetryConfig.quickRetry,
      );
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.handleFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      throw ErrorHandler.handleFirestoreError(e);
    } catch (e) {
      throw ErrorHandler.handleGenericError(e);
    }
  }

  /// Register new user
  Future<UserEntity> register({
    required String username,
    required String password,
    required String role,
    String? displayName,
  }) async {
    try {
      // Validate role
      if (role != AppConstants.roleEmployee && role != AppConstants.roleManager) {
        throw const ValidationException(
          message: 'Role tidak valid',
          code: 'INVALID_ROLE',
        );
      }

      return await RetryHelper.execute(
        operation: () async {
          // Convert username to email format
          final email = '$username@overtime.internal';

          // Create user in Firebase Auth
          final credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (credential.user == null) {
            throw const AuthException(
              message: 'Registrasi gagal, tidak ada user yang dikembalikan',
              code: 'NO_USER_RETURNED',
            );
          }

          // Create user document in Firestore
          final user = UserModel(
            id: credential.user!.uid,
            username: username,
            role: role,
            displayName: displayName,
            createdAt: DateTime.now(),
          );

          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(credential.user!.uid)
              .set(user.toFirestore());

          return user.toEntity();
        },
        config: RetryConfig.quickRetry,
      );
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.handleFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      throw ErrorHandler.handleFirestoreError(e);
    } catch (e) {
      throw ErrorHandler.handleGenericError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw ErrorHandler.handleFirebaseAuthError(e);
    } catch (e) {
      throw ErrorHandler.handleGenericError(e);
    }
  }

  /// Get current user
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final doc = await RetryHelper.execute(
        operation: () => _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get(),
        config: RetryConfig.quickRetry,
      );

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc).toEntity();
    } catch (e) {
      // Return null jika gagal get user
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
