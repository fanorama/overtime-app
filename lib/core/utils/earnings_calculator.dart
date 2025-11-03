import '../constants/app_constants.dart';
import 'date_time_utils.dart';

/// Utility class for calculating overtime earnings
class EarningsCalculator {
  /// Calculate total earnings for overtime work
  ///
  /// Formula: hours × base_rate × max(work_type_multipliers) + meal_allowance
  ///
  /// Returns a map with breakdown:
  /// - baseEarnings: hours × rate × multiplier
  /// - mealAllowance: fixed allowance
  /// - total: baseEarnings + mealAllowance
  static Map<String, double> calculate({
    required DateTime workDate,
    required double hours,
    required List<String> workTypes,
  }) {
    // Determine base rate based on weekend/weekday
    final double baseRate = DateTimeUtils.isWeekend(workDate)
        ? AppConstants.baseWeekendRate
        : AppConstants.baseWeekdayRate;

    // Get highest multiplier from selected work types
    final double multiplier = _getHighestMultiplier(workTypes);

    // Calculate base earnings
    final double baseEarnings = hours * baseRate * multiplier;

    // Fixed meal allowance
    final double mealAllowance = AppConstants.mealAllowance;

    // Total
    final double total = baseEarnings + mealAllowance;

    return {
      'baseEarnings': baseEarnings,
      'mealAllowance': mealAllowance,
      'total': total,
      'hourlyRate': baseRate,
      'multiplier': multiplier,
    };
  }

  /// Get the highest multiplier from selected work types
  static double _getHighestMultiplier(List<String> workTypes) {
    if (workTypes.isEmpty) {
      return 1.0;
    }

    double highest = 1.0;
    for (final workType in workTypes) {
      final multiplier = AppConstants.workTypeMultipliers[workType] ?? 1.0;
      if (multiplier > highest) {
        highest = multiplier;
      }
    }

    return highest;
  }

  /// Format currency to Indonesian Rupiah format
  static String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// Get breakdown text for display
  static String getBreakdownText({
    required double hours,
    required double hourlyRate,
    required double multiplier,
    required double baseEarnings,
    required double mealAllowance,
    required double total,
  }) {
    return '''
Perhitungan:
${hours.toStringAsFixed(1)} jam × ${formatCurrency(hourlyRate)} × $multiplier = ${formatCurrency(baseEarnings)}
Uang Makan = ${formatCurrency(mealAllowance)}
Total = ${formatCurrency(total)}
''';
  }

  /// Calculate earnings based on total hours, weekend status, work types, and employee count
  ///
  /// This method is used by SubmitOvertimeUseCase for earnings validation
  static double calculateEarnings({
    required double totalHours,
    required bool isWeekend,
    required List<String> workTypes,
    required int employeeCount,
  }) {
    if (employeeCount == 0 || workTypes.isEmpty || totalHours <= 0) {
      return 0.0;
    }

    // Determine base rate based on weekend status
    final double baseRate = isWeekend
        ? AppConstants.baseWeekendRate
        : AppConstants.baseWeekdayRate;

    // Get highest multiplier from selected work types
    final double multiplier = _getHighestMultiplier(workTypes);

    // Calculate base earnings per employee
    final double baseEarningsPerEmployee = totalHours * baseRate * multiplier;

    // Fixed meal allowance per employee
    final double mealAllowancePerEmployee = AppConstants.mealAllowance;

    // Total for all employees
    final double totalBaseEarnings = baseEarningsPerEmployee * employeeCount;
    final double totalMealAllowance = mealAllowancePerEmployee * employeeCount;

    return totalBaseEarnings + totalMealAllowance;
  }

  /// Calculate total earnings for multiple employees between start and end time
  static double calculateTotalEarnings({
    required DateTime startTime,
    required DateTime endTime,
    required List<String> workTypes,
    required int employeeCount,
  }) {
    if (employeeCount == 0 || workTypes.isEmpty) {
      return 0.0;
    }

    // Calculate hours between start and end
    final hours = endTime.difference(startTime).inMinutes / 60.0;
    if (hours <= 0) {
      return 0.0;
    }

    // For simplicity, use start date for rate determination
    final result = calculate(
      workDate: startTime,
      hours: hours,
      workTypes: workTypes,
    );

    // Multiply by employee count (excluding meal allowance which is per person)
    final baseEarnings = result['baseEarnings']! * employeeCount;
    final mealAllowance = result['mealAllowance']! * employeeCount;

    return baseEarnings + mealAllowance;
  }
}
