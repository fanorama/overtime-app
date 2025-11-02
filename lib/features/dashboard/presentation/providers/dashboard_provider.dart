import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../overtime/data/repositories/overtime_repository.dart';

/// Provider untuk overtime repository
final overtimeRepositoryProvider = Provider<OvertimeRepository>((ref) {
  return OvertimeRepository();
});

/// Provider untuk employee statistics
final employeeStatisticsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, EmployeeStatisticsParams>((ref, params) async {
  final repository = ref.watch(overtimeRepositoryProvider);
  return repository.getEmployeeStatistics(
    params.userId,
    params.startDate,
    params.endDate,
  );
});

/// Provider untuk manager statistics
final managerStatisticsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, ManagerStatisticsParams>((ref, params) async {
  final repository = ref.watch(overtimeRepositoryProvider);
  return repository.getManagerStatistics(
    params.startDate,
    params.endDate,
  );
});

/// Provider untuk date range selection (default: current month)
final dashboardDateRangeProvider =
    StateProvider.autoDispose<DateRangeSelection>((ref) {
  final now = DateTime.now();
  return DateRangeSelection(
    startDate: DateTime(now.year, now.month, 1),
    endDate: DateTime(now.year, now.month + 1, 0), // Last day of month
  );
});

/// Parameters untuk employee statistics
class EmployeeStatisticsParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  EmployeeStatisticsParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmployeeStatisticsParams &&
        other.userId == userId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(userId, startDate, endDate);
}

/// Parameters untuk manager statistics
class ManagerStatisticsParams {
  final DateTime startDate;
  final DateTime endDate;

  ManagerStatisticsParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManagerStatisticsParams &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate);
}

/// Date range selection for dashboard
class DateRangeSelection {
  final DateTime startDate;
  final DateTime endDate;

  DateRangeSelection({
    required this.startDate,
    required this.endDate,
  });

  String get displayText {
    // Format: "Jan 2025" or "Jan - Feb 2025" if cross-month
    final startMonth = _monthName(startDate.month);
    final endMonth = _monthName(endDate.month);
    final year = startDate.year;

    if (startDate.month == endDate.month) {
      return '$startMonth $year';
    } else {
      return '$startMonth - $endMonth $year';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }
}
