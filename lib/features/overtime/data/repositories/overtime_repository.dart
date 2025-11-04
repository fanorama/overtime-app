import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/overtime_request_model.dart';
import '../../domain/entities/overtime_request_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/security/authorization_helper.dart';
import '../../../../core/extensions/string_extensions.dart';

/// Repository untuk mengelola data overtime requests di Firestore
///
/// SECURITY: Repository ini menggunakan [AuthorizationHelper] untuk memverifikasi
/// permission sebelum melakukan operasi sensitive seperti approve, reject, update, delete.
class OvertimeRepository {
  final FirebaseFirestore _firestore;
  final AuthorizationHelper _authHelper;

  OvertimeRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authHelper = AuthorizationHelper(
          firestore: firestore,
          auth: auth,
        );

  /// Get collection reference
  CollectionReference get _collection =>
      _firestore.collection(AppConstants.overtimeRequestsCollection);

  /// Get all overtime requests (untuk manager)
  Stream<List<OvertimeRequestEntity>> getAllRequests() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get overtime requests by user ID
  Stream<List<OvertimeRequestEntity>> getRequestsByUser(String userId) {
    return _collection
        .where('submittedBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get overtime requests by status
  Stream<List<OvertimeRequestEntity>> getRequestsByStatus(String status) {
    return _collection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get overtime requests by user and status
  Stream<List<OvertimeRequestEntity>> getRequestsByUserAndStatus(
    String userId,
    String status,
  ) {
    return _collection
        .where('submittedBy', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get overtime requests by date range
  Stream<List<OvertimeRequestEntity>> getRequestsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) {
    Query query = _collection
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

    if (userId != null) {
      query = query.where('submittedBy', isEqualTo: userId);
    }

    return query.orderBy('startTime', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get pending requests (untuk manager)
  Stream<List<OvertimeRequestEntity>> getPendingRequests() {
    return getRequestsByStatus(AppConstants.statusPending);
  }

  /// Get overtime request by ID
  Future<OvertimeRequestEntity?> getRequestById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return OvertimeRequestModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get overtime request: $e');
    }
  }

  /// Get overtime request by ID as stream
  ///
  /// SECURITY: Uses hybrid approach based on user role:
  /// - Managers: Direct document access
  /// - Employees: Query by submittedBy and filter by ID client-side
  Stream<OvertimeRequestEntity?> getRequestByIdStream(String id) async* {
    final currentUserId = _authHelper.currentUserId;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Check user role to determine strategy
    bool isManager = false;
    try {
      isManager = await _authHelper.isCurrentUserManager();
      print('🔍 [DIAGNOSTIC] getRequestByIdStream - User is manager: $isManager');
    } catch (e) {
      print('⚠️ [DIAGNOSTIC] Error checking manager role: $e');
      // Default to non-manager approach if role check fails
      isManager = false;
    }

    if (isManager) {
      // MANAGER: Use direct document access
      print('📋 [DIAGNOSTIC] Using direct document access for manager');

      yield* _collection.doc(id).snapshots()
          .handleError((error) {
            print('❌ [DIAGNOSTIC] Manager access error: $error');
            // If manager has permission issues, fallback to query approach
            return null;
          })
          .map((doc) {
            if (doc.exists) {
              print('✅ [DIAGNOSTIC] Manager retrieved document $id');
              return OvertimeRequestModel.fromFirestore(doc);
            }
            print('❌ [DIAGNOSTIC] Document $id does not exist');
            return null;
          });
    } else {
      // EMPLOYEE: Query by submittedBy and filter client-side
      // This approach works around Firestore security rules limitations with compound queries
      print('📋 [DIAGNOSTIC] Using query approach for employee');

      yield* _collection
          .where('submittedBy', isEqualTo: currentUserId)
          .snapshots()
          .map((snapshot) {
        print('📄 [DIAGNOSTIC] Employee query returned ${snapshot.docs.length} documents');

        // Filter client-side to find the specific document
        try {
          final doc = snapshot.docs.firstWhere((doc) => doc.id == id);
          print('✅ [DIAGNOSTIC] Found document $id owned by user');
          return OvertimeRequestModel.fromFirestore(doc);
        } catch (e) {
          print('⚠️ [DIAGNOSTIC] Document $id not found or not owned by user');
          return null;
        }
      });
    }
  }

  /// Create new overtime request
  Future<String> createRequest(OvertimeRequestEntity request) async {
    try {
      final model = OvertimeRequestModel.fromEntity(request);
      final data = model.toFirestore();

      // Add server timestamp if not set
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _collection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create overtime request: $e');
    }
  }

  /// Update overtime request
  ///
  /// SECURITY: Verifies user permission before update
  /// - Owner can update pending requests
  /// - Manager can only update pending requests
  Future<void> updateRequest(String id, OvertimeRequestEntity request) async {
    try {
      print('🔶 [UPDATE REQUEST] Starting updateRequest for doc ID: $id');
      print('🔶 [UPDATE REQUEST] Request submittedBy: ${request.submittedBy}, status: ${request.status}');

      // SECURITY CHECK: Verify permission
      print('🔶 [UPDATE REQUEST] Verifying permissions...');
      final currentUserId = _authHelper.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _authHelper.verifyCanUpdateRequest(
        requestId: id,
        userId: currentUserId, // ✅ FIX: Use current user ID, not request owner
      );
      print('✅ [UPDATE REQUEST] Permission verified');

      final model = OvertimeRequestModel.fromEntity(request);
      final data = model.toFirestore();

      // ✅ CRITICAL FIX: Remove immutable fields for UPDATE operation
      // createdAt should never be modified after creation
      data.remove('createdAt');

      // Update timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      print('🔶 [UPDATE REQUEST] Data fields to update: ${data.keys.toList()}');
      print('🔶 [UPDATE REQUEST] Status: ${data['status']}, isEdited: ${data['isEdited']}');
      print('🔶 [UPDATE REQUEST] Approval fields present: approvedBy=${data.containsKey('approvedBy')}, approverName=${data.containsKey('approverName')}, approvedAt=${data.containsKey('approvedAt')}, rejectionReason=${data.containsKey('rejectionReason')}');
      print('🔶 [UPDATE REQUEST] Calculated earnings: ${data['calculatedEarnings']}, Meal: ${data['mealAllowance']}, Total: ${data['totalEarnings']}');
      print('🔶 [UPDATE REQUEST] Text field lengths: reportedProblem=${(data['reportedProblem'] as String).length}, workingDescription=${(data['workingDescription'] as String).length}');

      await _collection.doc(id).update(data);
      print('✅ [UPDATE REQUEST] Success! Document updated: $id');
    } catch (e, stackTrace) {
      print('❌ [UPDATE REQUEST] FAILED! Error: $e');
      print('❌ [UPDATE REQUEST] Stack trace: $stackTrace');
      print('❌ [UPDATE REQUEST] Document ID: $id, submittedBy: ${request.submittedBy}');
      throw Exception('Failed to update overtime request: $e');
    }
  }

  /// Delete overtime request
  ///
  /// SECURITY: Only owner can delete, and only if status is pending
  Future<void> deleteRequest(String id) async {
    try {
      // SECURITY CHECK: Get current user
      final currentUserId = _authHelper.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // SECURITY CHECK: Verify permission
      await _authHelper.verifyCanDeleteRequest(
        requestId: id,
        userId: currentUserId,
      );

      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete overtime request: $e');
    }
  }

  /// Approve overtime request
  ///
  /// SECURITY: Verifies approver is manager and request is pending
  Future<void> approveRequest(
    String id,
    String approverId,
    String approverName,
  ) async {
    try {
      // SECURITY CHECK: Verify permission to approve
      await _authHelper.verifyCanApproveRequest(
        requestId: id,
        approverId: approverId,
      );

      // Proceed with approval
      await _collection.doc(id).update({
        'status': AppConstants.statusApproved,
        'approvedBy': approverId,
        'approverName': approverName,
        'approvedAt': FieldValue.serverTimestamp(),
        'rejectionReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to approve overtime request: $e');
    }
  }

  /// Reject overtime request
  ///
  /// SECURITY: Verifies approver is manager and request is pending
  Future<void> rejectRequest(
    String id,
    String approverId,
    String approverName,
    String rejectionReason,
  ) async {
    try {
      // SECURITY CHECK: Verify permission to reject
      await _authHelper.verifyCanApproveRequest(
        requestId: id,
        approverId: approverId,
      );

      // Proceed with rejection
      await _collection.doc(id).update({
        'status': AppConstants.statusRejected,
        'approvedBy': approverId,
        'approverName': approverName,
        'approvedAt': FieldValue.serverTimestamp(),
        'rejectionReason': rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reject overtime request: $e');
    }
  }

  /// Reset status to pending (untuk re-approval setelah edit)
  Future<void> resetToPending(String id, Map<String, dynamic> editHistory) async {
    try {
      final doc = await _collection.doc(id).get();
      final data = doc.data() as Map<String, dynamic>;
      final currentHistory = List<Map<String, dynamic>>.from(
        data['editHistory'] ?? [],
      );

      await _collection.doc(id).update({
        'status': AppConstants.statusPending,
        'isEdited': true,
        'editHistory': [...currentHistory, editHistory],
        'approvedBy': null,
        'approverName': null,
        'approvedAt': null,
        'rejectionReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reset request to pending: $e');
    }
  }

  /// Get statistics for dashboard (employee)
  Future<Map<String, dynamic>> getEmployeeStatistics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _collection
          .where('submittedBy', isEqualTo: userId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final requests = snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();

      double totalHours = 0;
      double totalEarnings = 0;
      int pendingCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;

      for (final request in requests) {
        totalHours += request.totalHours;

        // Use extension for status comparison (case-insensitive)
        if (request.status.isApproved) {
          totalEarnings += request.totalEarnings;
          approvedCount++;
        } else if (request.status.isPending) {
          pendingCount++;
        } else if (request.status.isRejected) {
          rejectedCount++;
        }
      }

      return {
        'totalHours': totalHours,
        'totalEarnings': totalEarnings,
        'totalRequests': requests.length,
        'pendingCount': pendingCount,
        'approvedCount': approvedCount,
        'rejectedCount': rejectedCount,
      };
    } catch (e) {
      throw Exception('Failed to get employee statistics: $e');
    }
  }

  /// Get statistics for dashboard (manager)
  Future<Map<String, dynamic>> getManagerStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _collection
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final requests = snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();

      double totalHours = 0;
      double totalEarnings = 0;
      int pendingCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;

      // Top employees by hours
      final Map<String, double> employeeHours = {};
      final Map<String, String> employeeNames = {};

      // Severity breakdown
      final Map<String, int> severityBreakdown = {
        'LOW': 0,
        'MEDIUM': 0,
        'HIGH': 0,
        'CRITICAL': 0,
      };

      for (final request in requests) {
        totalHours += request.totalHours;

        // Use extension for status comparison (case-insensitive)
        if (request.status.isApproved) {
          totalEarnings += request.totalEarnings;
          approvedCount++;
        } else if (request.status.isPending) {
          pendingCount++;
        } else if (request.status.isRejected) {
          rejectedCount++;
        }

        // Track employee hours
        if (!employeeHours.containsKey(request.submittedBy)) {
          employeeHours[request.submittedBy] = 0;
          employeeNames[request.submittedBy] = request.submitterName;
        }
        employeeHours[request.submittedBy] =
            employeeHours[request.submittedBy]! + request.totalHours;

        // Track severity - normalize to uppercase for map key
        final severityKey = request.severity.toUpperCase();
        severityBreakdown[severityKey] =
            (severityBreakdown[severityKey] ?? 0) + 1;
      }

      // Get top 5 employees by hours
      final topEmployees = employeeHours.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final top5 = topEmployees.take(5).map((entry) => {
        'userId': entry.key,
        'name': employeeNames[entry.key],
        'hours': entry.value,
      }).toList();

      return {
        'totalHours': totalHours,
        'totalEarnings': totalEarnings,
        'totalRequests': requests.length,
        'pendingCount': pendingCount,
        'approvedCount': approvedCount,
        'rejectedCount': rejectedCount,
        'topEmployees': top5,
        'severityBreakdown': severityBreakdown,
      };
    } catch (e) {
      throw Exception('Failed to get manager statistics: $e');
    }
  }
}
