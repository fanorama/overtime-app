import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

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
      // Convert username to email format for Firebase
      final email = '$username@overtime.internal';

      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed: No user returned');
      }

      // Get user data from Firestore
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User data not found in database');
      }

      return UserModel.fromFirestore(doc).toEntity();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Username tidak ditemukan');
        case 'wrong-password':
          throw Exception('Password salah');
        case 'invalid-email':
          throw Exception('Format username tidak valid');
        case 'user-disabled':
          throw Exception('Akun telah dinonaktifkan');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan login. Coba lagi nanti');
        default:
          throw Exception('Login gagal: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login gagal: ${e.toString()}');
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
        throw Exception('Role tidak valid');
      }

      // Convert username to email format
      final email = '$username@overtime.internal';

      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Registration failed: No user returned');
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
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Username sudah digunakan');
        case 'weak-password':
          throw Exception('Password terlalu lemah');
        case 'invalid-email':
          throw Exception('Format username tidak valid');
        default:
          throw Exception('Registrasi gagal: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout gagal: ${e.toString()}');
    }
  }

  /// Get current user
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc).toEntity();
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
