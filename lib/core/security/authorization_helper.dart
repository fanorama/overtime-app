import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../exceptions/app_exception.dart';

/// Helper untuk authorization checks
///
/// Class ini menyediakan utility methods untuk memverifikasi permission
/// dan access control di berbagai operasi aplikasi.
///
/// SECURITY NOTE: Semua method async karena perlu fetch data dari Firestore
class AuthorizationHelper {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthorizationHelper({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if current user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Verify user has manager role
  ///
  /// Throws [AuthException.unauthorized] if not authenticated
  /// Throws [AuthException.unauthorized] if not a manager
  /// Returns [true] if user is manager
  Future<bool> verifyIsManager([String? userId]) async {
    final uid = userId ?? currentUserId;

    if (uid == null) {
      throw AuthException.unauthorized();
    }

    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      throw AuthException.userNotFound();
    }

    final role = userDoc.data()?['role'] as String?;

    if (role != AppConstants.roleManager) {
      throw AuthException.unauthorized();
    }

    return true;
  }

  /// Verify user is the owner of a resource
  ///
  /// Throws [AuthException.unauthorized] if not authenticated
  /// Throws [OperationNotAllowedException.unauthorized] if not owner
  Future<bool> verifyIsOwner(String resourceOwnerId) async {
    if (!isAuthenticated) {
      throw AuthException.unauthorized();
    }

    if (currentUserId != resourceOwnerId) {
      throw OperationNotAllowedException.unauthorized();
    }

    return true;
  }

  /// Verify user can approve overtime requests
  ///
  /// Requirements:
  /// 1. User must be authenticated
  /// 2. User must have manager role
  /// 3. Request must exist
  /// 4. Request status must be pending
  Future<void> verifyCanApproveRequest({
    required String requestId,
    required String approverId,
  }) async {
    // 1. Verify approver is manager
    await verifyIsManager(approverId);

    // 2. Verify request exists and is pending
    final requestDoc = await _firestore
        .collection(AppConstants.overtimeRequestsCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      throw DataNotFoundException.overtimeRequest();
    }

    final status = requestDoc.data()?['status'] as String?;

    if (status == null) {
      throw ValidationException(
        message: 'Status request tidak valid',
        code: 'INVALID_STATUS',
      );
    }

    // Normalize status comparison (case-insensitive)
    if (status.toLowerCase() != AppConstants.statusPending) {
      throw OperationNotAllowedException(
        message: 'Hanya request dengan status pending yang bisa disetujui atau ditolak',
        code: 'NOT_PENDING',
      );
    }
  }

  /// Verify user can update overtime request
  ///
  /// Requirements:
  /// 1. User must be authenticated
  /// 2. User must be the owner OR a manager
  /// 3. Request must exist
  /// 4. If not owner, request must be pending (only owner can edit approved/rejected)
  Future<void> verifyCanUpdateRequest({
    required String requestId,
    required String userId,
  }) async {
    if (!isAuthenticated) {
      throw AuthException.unauthorized();
    }

    // Get request data
    final requestDoc = await _firestore
        .collection(AppConstants.overtimeRequestsCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      throw DataNotFoundException.overtimeRequest();
    }

    final requestData = requestDoc.data()!;
    final ownerId = requestData['submittedBy'] as String?;
    final status = requestData['status'] as String?;

    if (ownerId == null) {
      throw ValidationException(
        message: 'Data request tidak valid (submittedBy missing)',
        code: 'INVALID_REQUEST_DATA',
      );
    }

    // Check if user is owner
    final isOwner = currentUserId == ownerId;

    if (!isOwner) {
      // If not owner, must be manager
      await verifyIsManager(userId);

      // Manager can only update pending requests
      if (status?.toLowerCase() != AppConstants.statusPending) {
        throw OperationNotAllowedException(
          message: 'Manager hanya bisa update request dengan status pending',
          code: 'NOT_PENDING',
        );
      }
    }
  }

  /// Verify user can delete overtime request
  ///
  /// Requirements:
  /// 1. User must be authenticated
  /// 2. User must be the owner
  /// 3. Request must exist
  /// 4. Request status must be pending (cannot delete approved/rejected)
  Future<void> verifyCanDeleteRequest({
    required String requestId,
    required String userId,
  }) async {
    if (!isAuthenticated) {
      throw AuthException.unauthorized();
    }

    // Get request data
    final requestDoc = await _firestore
        .collection(AppConstants.overtimeRequestsCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      throw DataNotFoundException.overtimeRequest();
    }

    final requestData = requestDoc.data()!;
    final ownerId = requestData['submittedBy'] as String?;
    final status = requestData['status'] as String?;

    if (ownerId == null) {
      throw ValidationException(
        message: 'Data request tidak valid (submittedBy missing)',
        code: 'INVALID_REQUEST_DATA',
      );
    }

    // Verify user is owner
    await verifyIsOwner(ownerId);

    // Verify status is pending
    if (status?.toLowerCase() != AppConstants.statusPending) {
      throw OperationNotAllowedException(
        message: 'Hanya request dengan status pending yang bisa dihapus',
        code: 'CANNOT_DELETE_PROCESSED',
      );
    }
  }

  /// Verify overtime data integrity
  ///
  /// Prevents manipulation of calculated fields like earnings
  Future<void> verifyOvertimeDataIntegrity({
    required double submittedEarnings,
    required double calculatedEarnings,
  }) async {
    // Allow small floating point difference (0.01)
    const tolerance = 0.01;

    if ((submittedEarnings - calculatedEarnings).abs() > tolerance) {
      throw ValidationException(
        message: 'Data earnings tidak sesuai dengan kalkulasi sistem',
        code: 'EARNINGS_MISMATCH',
      );
    }
  }
}
