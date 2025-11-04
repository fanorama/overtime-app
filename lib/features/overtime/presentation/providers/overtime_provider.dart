import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/overtime_repository.dart';
import '../../domain/entities/overtime_request_entity.dart';

/// Provider untuk OvertimeRepository
final overtimeRepositoryProvider = Provider<OvertimeRepository>((ref) {
  return OvertimeRepository();
});

/// Provider untuk stream semua overtime requests (untuk manager)
final allOvertimeRequestsStreamProvider =
    StreamProvider<List<OvertimeRequestEntity>>((ref) {
  final repository = ref.watch(overtimeRepositoryProvider);
  return repository.getAllRequests();
});

/// Provider untuk stream overtime requests by user
final userOvertimeRequestsStreamProvider =
    StreamProvider.family<List<OvertimeRequestEntity>, String>((ref, userId) {
  final repository = ref.watch(overtimeRepositoryProvider);
  return repository.getRequestsByUser(userId);
});

/// Provider untuk stream overtime requests by status
final overtimeRequestsByStatusStreamProvider =
    StreamProvider.family<List<OvertimeRequestEntity>, String>((ref, status) {
  final repository = ref.watch(overtimeRepositoryProvider);
  return repository.getRequestsByStatus(status);
});

/// Provider untuk stream pending overtime requests (untuk manager)
final pendingOvertimeRequestsStreamProvider =
    StreamProvider<List<OvertimeRequestEntity>>((ref) {
  final repository = ref.watch(overtimeRepositoryProvider);
  return repository.getPendingRequests();
});

/// Provider untuk get single overtime request by ID
final overtimeRequestByIdStreamProvider = StreamProvider.family<
    OvertimeRequestEntity?, String>((ref, id) {
  final repository = ref.watch(overtimeRepositoryProvider);
  return repository.getRequestByIdStream(id);
});

/// Provider untuk filter parameters
class OvertimeFilterParams {
  final String? userId;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  OvertimeFilterParams({
    this.userId,
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OvertimeFilterParams &&
        other.userId == userId &&
        other.status == status &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        status.hashCode ^
        startDate.hashCode ^
        endDate.hashCode;
  }
}

/// Provider untuk filtered overtime requests
final filteredOvertimeRequestsStreamProvider = StreamProvider.family<
    List<OvertimeRequestEntity>, OvertimeFilterParams>((ref, params) {
  final repository = ref.watch(overtimeRepositoryProvider);

  // If date range is specified, use date range query
  if (params.startDate != null && params.endDate != null) {
    return repository.getRequestsByDateRange(
      params.startDate!,
      params.endDate!,
      userId: params.userId,
    );
  }

  // If both userId and status are specified
  if (params.userId != null && params.status != null) {
    return repository.getRequestsByUserAndStatus(params.userId!, params.status!);
  }

  // If only userId is specified
  if (params.userId != null) {
    return repository.getRequestsByUser(params.userId!);
  }

  // If only status is specified
  if (params.status != null) {
    return repository.getRequestsByStatus(params.status!);
  }

  // Default: all requests
  return repository.getAllRequests();
});

/// Controller untuk overtime operations
final overtimeControllerProvider =
    StateNotifierProvider<OvertimeController, AsyncValue<void>>((ref) {
  return OvertimeController(
    repository: ref.watch(overtimeRepositoryProvider),
  );
});

/// Controller class untuk handle overtime CRUD operations
class OvertimeController extends StateNotifier<AsyncValue<void>> {
  final OvertimeRepository repository;

  OvertimeController({required this.repository})
      : super(const AsyncValue.data(null));

  /// Create new overtime request
  Future<String?> createRequest(OvertimeRequestEntity request) async {
    print('🎯 [CONTROLLER] createRequest called');
    state = const AsyncValue.loading();
    try {
      final id = await repository.createRequest(request);
      print('✅ [CONTROLLER] createRequest success, ID: $id');
      state = const AsyncValue.data(null);
      return id;
    } catch (e, stack) {
      print('❌ [CONTROLLER] createRequest FAILED! Error: $e');
      print('❌ [CONTROLLER] Stack: $stack');
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update overtime request
  Future<bool> updateRequest(String id, OvertimeRequestEntity request) async {
    print('🎯 [CONTROLLER] updateRequest called for ID: $id');
    state = const AsyncValue.loading();
    try {
      await repository.updateRequest(id, request);
      print('✅ [CONTROLLER] updateRequest success');
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      print('❌ [CONTROLLER] updateRequest FAILED! Error: $e');
      print('❌ [CONTROLLER] Stack: $stack');
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Delete overtime request
  Future<bool> deleteRequest(String id) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteRequest(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Approve overtime request
  Future<bool> approveRequest(
    String id,
    String approverId,
    String approverName,
  ) async {
    state = const AsyncValue.loading();
    try {
      await repository.approveRequest(id, approverId, approverName);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Reject overtime request
  Future<bool> rejectRequest(
    String id,
    String approverId,
    String approverName,
    String rejectionReason,
  ) async {
    state = const AsyncValue.loading();
    try {
      await repository.rejectRequest(id, approverId, approverName, rejectionReason);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Reset status to pending (untuk re-approval)
  Future<bool> resetToPending(String id, Map<String, dynamic> editHistory) async {
    state = const AsyncValue.loading();
    try {
      await repository.resetToPending(id, editHistory);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Get employee statistics
  Future<Map<String, dynamic>?> getEmployeeStatistics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await repository.getEmployeeStatistics(userId, startDate, endDate);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Get manager statistics
  Future<Map<String, dynamic>?> getManagerStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await repository.getManagerStatistics(startDate, endDate);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}
