import '../../data/repositories/overtime_repository.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/extensions/string_extensions.dart';

/// Use case untuk reject overtime request
///
/// Business Rules:
/// 1. Only managers can reject
/// 2. Only pending requests can be rejected
/// 3. Rejection reason must be provided
/// 4. Request must exist
/// 5. Authorization checks are handled by repository
class RejectOvertimeUseCase {
  final OvertimeRepository _repository;

  RejectOvertimeUseCase(this._repository);

  /// Execute rejection
  ///
  /// Throws [ValidationException] if rejection reason empty
  /// Throws [AuthException] if not manager
  /// Throws [DataNotFoundException] if request not found
  /// Throws [OperationNotAllowedException] if not pending
  Future<void> execute({
    required String requestId,
    required String approverId,
    required String approverName,
    required String rejectionReason,
  }) async {
    try {
      // Validate rejection reason
      if (rejectionReason.trim().isEmpty) {
        throw ValidationException(
          message: 'Alasan penolakan wajib diisi',
          code: 'REJECTION_REASON_REQUIRED',
        );
      }

      if (rejectionReason.trim().length < 10) {
        throw ValidationException(
          message: 'Alasan penolakan minimal 10 karakter',
          code: 'REJECTION_REASON_TOO_SHORT',
        );
      }

      // Get request to validate
      final request = await _repository.getRequestById(requestId);

      if (request == null) {
        throw DataNotFoundException.overtimeRequest();
      }

      // Validate business rules
      if (!request.status.canBeProcessed) {
        throw OperationNotAllowedException(
          message: 'Request dengan status ${request.status} tidak bisa ditolak',
          code: 'NOT_PROCESSABLE',
        );
      }

      // Repository will do authorization check internally
      await _repository.rejectRequest(
        requestId,
        approverId,
        approverName,
        rejectionReason.trim(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
