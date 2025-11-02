import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/overtime_request_model.dart';
import '../../domain/entities/overtime_request_entity.dart';
import '../../../../core/constants/app_constants.dart';

/// Repository untuk mengelola data overtime requests di Firestore
class OvertimeRepository {
  final FirebaseFirestore _firestore;

  OvertimeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
    return getRequestsByStatus('PENDING');
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
  Stream<OvertimeRequestEntity?> getRequestByIdStream(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return OvertimeRequestModel.fromFirestore(doc);
      }
      return null;
    });
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
  Future<void> updateRequest(String id, OvertimeRequestEntity request) async {
    try {
      final model = OvertimeRequestModel.fromEntity(request);
      final data = model.toFirestore();

      // Update timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _collection.doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update overtime request: $e');
    }
  }

  /// Delete overtime request
  Future<void> deleteRequest(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete overtime request: $e');
    }
  }

  /// Approve overtime request
  Future<void> approveRequest(
    String id,
    String approverId,
    String approverName,
  ) async {
    try {
      await _collection.doc(id).update({
        'status': 'APPROVED',
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
  Future<void> rejectRequest(
    String id,
    String approverId,
    String approverName,
    String rejectionReason,
  ) async {
    try {
      await _collection.doc(id).update({
        'status': 'REJECTED',
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
        'status': 'PENDING',
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
        final statusUpper = request.status.toUpperCase();
        if (statusUpper == 'APPROVED') {
          totalEarnings += request.totalEarnings;
          approvedCount++;
        } else if (statusUpper == 'PENDING') {
          pendingCount++;
        } else if (statusUpper == 'REJECTED') {
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

        final statusUpper = request.status.toUpperCase();
        if (statusUpper == 'APPROVED') {
          totalEarnings += request.totalEarnings;
          approvedCount++;
        } else if (statusUpper == 'PENDING') {
          pendingCount++;
        } else if (statusUpper == 'REJECTED') {
          rejectedCount++;
        }

        // Track employee hours
        if (!employeeHours.containsKey(request.submittedBy)) {
          employeeHours[request.submittedBy] = 0;
          employeeNames[request.submittedBy] = request.submitterName;
        }
        employeeHours[request.submittedBy] =
            employeeHours[request.submittedBy]! + request.totalHours;

        // Track severity
        final severityUpper = request.severity.toUpperCase();
        severityBreakdown[severityUpper] =
            (severityBreakdown[severityUpper] ?? 0) + 1;
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
