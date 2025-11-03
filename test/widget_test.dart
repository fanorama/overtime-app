// Widget tests for Overtime App - Phase 2
// Note: Firebase tests skipped until actual Firebase configuration
import 'package:flutter_test/flutter_test.dart';
import 'package:overtime_app/core/utils/earnings_calculator.dart';
import 'package:overtime_app/core/utils/date_time_utils.dart';
import 'package:overtime_app/core/validators/form_validators.dart';
import 'package:overtime_app/core/constants/app_constants.dart';

void main() {
  group('Core Utilities Tests', () {
    test('Earnings calculator - weekday calculation', () {
      final workDate = DateTime(2025, 11, 3); // Monday
      const hours = 4.0;
      const workTypes = [AppConstants.workTypeCall]; // 1.2 multiplier

      final result = EarningsCalculator.calculate(
        workDate: workDate,
        hours: hours,
        workTypes: workTypes,
      );

      // Expected: 4 hours × 50000 (weekday) × 1.2 (Call) = 240000 + 25000 = 265000
      expect(result['total'], 265000);
    });

    test('Date utils - weekend detection', () {
      final saturday = DateTime(2025, 11, 1);
      final monday = DateTime(2025, 11, 3);

      expect(DateTimeUtils.isWeekend(saturday), true);
      expect(DateTimeUtils.isWeekend(monday), false);
    });

    test('Form validators - username validation', () {
      expect(FormValidators.username('abc'), null);
      expect(FormValidators.username('ab'), contains('minimal'));
      expect(FormValidators.username(''), contains('wajib'));
    });
  });

  // TODO: Add Firebase-based widget tests after Firebase configuration
  // Phase 2 authentication screens tested manually - pending Firebase setup
}
