import 'package:flutter_test/flutter_test.dart';
import 'package:overtime_app/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    group('isWeekend', () {
      test('should return true for Saturday', () {
        final saturday = DateTime(2025, 11, 1); // Saturday
        expect(DateTimeUtils.isWeekend(saturday), true);
      });

      test('should return true for Sunday', () {
        final sunday = DateTime(2025, 11, 2); // Sunday
        expect(DateTimeUtils.isWeekend(sunday), true);
      });

      test('should return false for weekdays', () {
        final monday = DateTime(2025, 11, 3); // Monday
        final tuesday = DateTime(2025, 11, 4); // Tuesday
        final friday = DateTime(2025, 11, 7); // Friday

        expect(DateTimeUtils.isWeekend(monday), false);
        expect(DateTimeUtils.isWeekend(tuesday), false);
        expect(DateTimeUtils.isWeekend(friday), false);
      });
    });

    group('calculateHours', () {
      test('should calculate hours correctly', () {
        final start = DateTime(2025, 11, 3, 9, 0);
        final end = DateTime(2025, 11, 3, 13, 0);

        expect(DateTimeUtils.calculateHours(start, end), 4.0);
      });

      test('should handle fractional hours', () {
        final start = DateTime(2025, 11, 3, 9, 0);
        final end = DateTime(2025, 11, 3, 11, 30);

        expect(DateTimeUtils.calculateHours(start, end), 2.5);
      });

      test('should handle overnight work', () {
        final start = DateTime(2025, 11, 3, 22, 0);
        final end = DateTime(2025, 11, 4, 2, 0);

        expect(DateTimeUtils.calculateHours(start, end), 4.0);
      });
    });

    group('date range helpers', () {
      test('startOfDay should return midnight', () {
        final date = DateTime(2025, 11, 3, 15, 30, 45);
        final result = DateTimeUtils.startOfDay(date);

        expect(result.year, 2025);
        expect(result.month, 11);
        expect(result.day, 3);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
      });

      test('endOfDay should return last moment of day', () {
        final date = DateTime(2025, 11, 3, 10, 0);
        final result = DateTimeUtils.endOfDay(date);

        expect(result.year, 2025);
        expect(result.month, 11);
        expect(result.day, 3);
        expect(result.hour, 23);
        expect(result.minute, 59);
        expect(result.second, 59);
      });

      test('startOfMonth should return first day of month', () {
        final date = DateTime(2025, 11, 15);
        final result = DateTimeUtils.startOfMonth(date);

        expect(result.day, 1);
        expect(result.month, 11);
        expect(result.year, 2025);
      });

      test('endOfMonth should return last day of month', () {
        final date = DateTime(2025, 11, 15);
        final result = DateTimeUtils.endOfMonth(date);

        expect(result.day, 30); // November has 30 days
        expect(result.month, 11);
        expect(result.year, 2025);
      });
    });

    group('combineDateTime', () {
      test('should combine date and time correctly', () {
        final date = DateTime(2025, 11, 3);
        final time = DateTime(2025, 1, 1, 14, 30);

        final result = DateTimeUtils.combineDateTime(date, time);

        expect(result.year, 2025);
        expect(result.month, 11);
        expect(result.day, 3);
        expect(result.hour, 14);
        expect(result.minute, 30);
      });
    });
  });
}
