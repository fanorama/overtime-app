import '../../data/repositories/overtime_repository.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/extensions/string_extensions.dart';

/// Use case untuk approve overtime request
///
/// Business Rules:
/// 1. Only managers can approve
/// 2. Only pending requests can be approved
/// 3. Request must exist
/// 4. Authorization checks are handled by repository
class ApproveOvertimeUseCase {
  final OvertimeRepository _repository;

  ApproveOvertimeUseCase(this._repository);

  /// Execute approval
  ///
  /// Throws [AuthException] if not manager
  /// Throws [DataNotFoundException] if request not found
  /// Throws [OperationNotAllowedException] if not pending
  Future<void> execute({
    required String requestId,
    required String approverId,
    required String approverName,
  }) async {
    try {
      // Get request to validate
      final request = await _repository.getRequestById(requestId);

      if (request == null) {
        throw DataNotFoundException.overtimeRequest();
      }

      // Validate business rules (additional layer)
      if (!request.status.canBeProcessed) {
        throw OperationNotAllowedException(
          message:
              'Request dengan status ${request.status} tidak bisa disetujui',
          code: 'NOT_PROCESSABLE',
        );
      }

      // Repository will do authorization check internally
      await _repository.approveRequest(
        requestId,
        approverId,
        approverName,
      );
    } catch (e) {
      // Let specific exceptions bubble up
      rethrow;
    }
  }
}
