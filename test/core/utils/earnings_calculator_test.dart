import 'package:flutter_test/flutter_test.dart';
import 'package:overtime_app/core/utils/earnings_calculator.dart';
import 'package:overtime_app/core/constants/app_constants.dart';

void main() {
  group('EarningsCalculator', () {
    group('calculate', () {
      test('should calculate weekday earnings correctly', () {
        // Arrange
        final workDate = DateTime(2025, 11, 3); // Monday
        const hours = 4.0;
        const workTypes = [AppConstants.workTypeInstallation];

        // Act
        final result = EarningsCalculator.calculate(
          workDate: workDate,
          hours: hours,
          workTypes: workTypes,
        );

        // Assert
        expect(result['hourlyRate'], AppConstants.baseWeekdayRate);
        expect(result['multiplier'], 1.2); // Installation multiplier
        expect(result['baseEarnings'], 50000 * 4.0 * 1.2); // 240,000
        expect(result['mealAllowance'], AppConstants.mealAllowance);
        expect(result['total'], 240000 + 25000); // 265,000
      });

      test('should calculate weekend earnings with higher rate', () {
        // Arrange
        final workDate = DateTime(2025, 11, 1); // Saturday
        const hours = 3.0;
        const workTypes = [AppConstants.workTypeRepair];

        // Act
        final result = EarningsCalculator.calculate(
          workDate: workDate,
          hours: hours,
          workTypes: workTypes,
        );

        // Assert
        expect(result['hourlyRate'], AppConstants.baseWeekendRate);
        expect(result['multiplier'], 1.5); // Repair multiplier
        expect(result['baseEarnings'], 75000 * 3.0 * 1.5); // 337,500
        expect(result['total'], 337500 + 25000); // 362,500
      });

      test('should use highest multiplier when multiple work types selected',
          () {
        // Arrange
        final workDate = DateTime(2025, 11, 3);
        const hours = 2.0;
        const workTypes = [
          AppConstants.workTypePreventive, // 1.0
          AppConstants.workTypeRepair, // 1.5
          AppConstants.workTypeInstallation, // 1.2
        ];

        // Act
        final result = EarningsCalculator.calculate(
          workDate: workDate,
          hours: hours,
          workTypes: workTypes,
        );

        // Assert
        expect(result['multiplier'], 1.5); // Highest is Repair
      });

      test('should default to 1.0 multiplier for empty work types', () {
        // Arrange
        final workDate = DateTime(2025, 11, 3);
        const hours = 2.0;
        const workTypes = <String>[];

        // Act
        final result = EarningsCalculator.calculate(
          workDate: workDate,
          hours: hours,
          workTypes: workTypes,
        );

        // Assert
        expect(result['multiplier'], 1.0);
      });

      test('should include meal allowance in total', () {
        // Arrange
        final workDate = DateTime(2025, 11, 3);
        const hours = 1.0;
        const workTypes = [AppConstants.workTypeMonitoring];

        // Act
        final result = EarningsCalculator.calculate(
          workDate: workDate,
          hours: hours,
          workTypes: workTypes,
        );

        // Assert
        expect(result['mealAllowance'], 25000);
        expect(
          result['total'],
          result['baseEarnings']! + result['mealAllowance']!,
        );
      });
    });

    group('formatCurrency', () {
      test('should format currency with thousand separators', () {
        expect(EarningsCalculator.formatCurrency(100000), 'Rp 100.000');
        expect(EarningsCalculator.formatCurrency(1000000), 'Rp 1.000.000');
        expect(EarningsCalculator.formatCurrency(265000), 'Rp 265.000');
      });

      test('should handle zero and small amounts', () {
        expect(EarningsCalculator.formatCurrency(0), 'Rp 0');
        expect(EarningsCalculator.formatCurrency(500), 'Rp 500');
      });
    });
  });
}
