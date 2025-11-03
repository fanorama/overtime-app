import '../entities/overtime_request_entity.dart';
import '../../data/repositories/overtime_repository.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/earnings_calculator.dart';

/// Use case untuk submit overtime request
///
/// Business Rules:
/// 1. User must be authenticated
/// 2. All required fields must be filled
/// 3. Time range must be valid
/// 4. At least 1 employee involved
/// 5. At least 1 work type selected
/// 6. Earnings calculation must match
class SubmitOvertimeUseCase {
  final OvertimeRepository _repository;

  SubmitOvertimeUseCase(this._repository);

  /// Execute submission
  ///
  /// Validates business rules and calculates earnings
  /// Returns request ID if successful
  ///
  /// Throws [ValidationException] if validation fails
  Future<String> execute({
    required OvertimeRequestEntity request,
  }) async {
    try {
      // Validate business rules
      _validateRequest(request);

      // Verify earnings calculation integrity
      final calculatedEarnings = EarningsCalculator.calculateEarnings(
        totalHours: request.totalHours,
        isWeekend: request.isWeekend,
        workTypes: request.typeOfWork,
        employeeCount: _getTotalEmployees(request),
      );

      // Allow small floating point difference (0.01)
      const tolerance = 0.01;
      if ((request.calculatedEarnings - calculatedEarnings).abs() >
          tolerance) {
        throw ValidationException(
          message: 'Kalkulasi earnings tidak sesuai dengan sistem',
          code: 'EARNINGS_MISMATCH',
        );
      }

      // Submit to repository
      return await _repository.createRequest(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Validate overtime request
  void _validateRequest(OvertimeRequestEntity request) {
    // Validate time range
    if (request.endTime.isBefore(request.startTime)) {
      throw ValidationException(
        message: 'Waktu selesai harus lebih besar dari waktu mulai',
        code: 'INVALID_TIME_RANGE',
      );
    }

    // Validate duration (max 24 hours)
    final duration = request.endTime.difference(request.startTime);
    if (duration.inHours > 24) {
      throw ValidationException(
        message: 'Durasi lembur tidak boleh lebih dari 24 jam',
        code: 'DURATION_TOO_LONG',
      );
    }

    // Validate employee involvement
    final totalEmployees = _getTotalEmployees(request);
    if (totalEmployees == 0) {
      throw ValidationException(
        message: 'Minimal 1 karyawan harus terlibat',
        code: 'NO_EMPLOYEES',
      );
    }

    // Validate work types
    if (request.typeOfWork.isEmpty) {
      throw ValidationException(
        message: 'Minimal 1 jenis pekerjaan harus dipilih',
        code: 'NO_WORK_TYPES',
      );
    }

    // Validate required fields
    if (request.customer.trim().isEmpty) {
      throw ValidationException.requiredField('Customer');
    }

    if (request.reportedProblem.trim().isEmpty) {
      throw ValidationException.requiredField('Reported Problem');
    }

    if (request.workingDescription.trim().isEmpty) {
      throw ValidationException.requiredField('Working Description');
    }

    if (request.product.trim().isEmpty) {
      throw ValidationException.requiredField('Product');
    }
  }

  /// Get total employees involved
  int _getTotalEmployees(OvertimeRequestEntity request) {
    return request.involvedEngineers.length +
        request.involvedMaintenance.length +
        request.involvedPostsales.length;
  }
}
