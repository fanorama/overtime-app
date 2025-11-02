import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../overtime/presentation/screens/manager_request_list_screen.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_breakdown_widget.dart';
import '../widgets/top_employees_widget.dart';
import '../widgets/severity_breakdown_widget.dart';

/// Manager Dashboard Screen - menampilkan team overview metrics
class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final dateRange = ref.watch(dashboardDateRangeProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final params = ManagerStatisticsParams(
      startDate: dateRange.startDate,
      endDate: dateRange.endDate,
    );

    final statisticsAsync = ref.watch(managerStatisticsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Pilih Periode',
            onPressed: () => _showDateRangePicker(context, ref, dateRange),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(managerStatisticsProvider(params));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, user.displayName ?? user.username),
              const SizedBox(height: 8),
              _buildDateRangeChip(dateRange),
              const SizedBox(height: 24),

              // Statistics
              statisticsAsync.when(
                data: (stats) => _buildStatistics(context, ref, stats),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Manager',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Halo, $name!',
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeChip(DateRangeSelection dateRange) {
    return Chip(
      avatar: const Icon(Icons.date_range, size: 18),
      label: Text(
        dateRange.displayText,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
    );
  }

  Widget _buildStatistics(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> stats,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final totalHours = (stats['totalHours'] as num?)?.toDouble() ?? 0.0;
    final totalEarnings = (stats['totalEarnings'] as num?)?.toDouble() ?? 0.0;
    final totalRequests = stats['totalRequests'] as int? ?? 0;
    final pendingCount = stats['pendingCount'] as int? ?? 0;
    final approvedCount = stats['approvedCount'] as int? ?? 0;
    final rejectedCount = stats['rejectedCount'] as int? ?? 0;
    final topEmployees =
        (stats['topEmployees'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final severityBreakdown =
        (stats['severityBreakdown'] as Map<String, dynamic>?)?.cast<String, int>() ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metrics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            MetricCard(
              title: 'Total Jam Tim',
              value: totalHours.toStringAsFixed(1),
              icon: Icons.access_time,
              color: AppTheme.primaryColor,
              subtitle: 'jam kerja lembur',
            ),
            MetricCard(
              title: 'Total Biaya',
              value: currencyFormat.format(totalEarnings),
              icon: Icons.payments,
              color: AppTheme.successColor,
              subtitle: 'biaya lembur approved',
            ),
            MetricCard(
              title: 'Total Request',
              value: totalRequests.toString(),
              icon: Icons.list_alt,
              color: AppTheme.infoColor,
              subtitle: 'pengajuan lembur',
            ),
            MetricCard(
              title: 'Pending',
              value: pendingCount.toString(),
              icon: Icons.pending_actions,
              color: AppTheme.warningColor,
              subtitle: 'menunggu approval',
              onTap: () {
                // Navigate to pending requests
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagerRequestListScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Status Breakdown
        StatusBreakdownWidget(
          pendingCount: pendingCount,
          approvedCount: approvedCount,
          rejectedCount: rejectedCount,
        ),

        const SizedBox(height: 16),

        // Top Employees
        TopEmployeesWidget(topEmployees: topEmployees),

        const SizedBox(height: 16),

        // Severity Breakdown
        SeverityBreakdownWidget(severityBreakdown: severityBreakdown),

        const SizedBox(height: 16),

        // Quick Info Cards
        if (totalRequests > 0) ...[
          Card(
            elevation: 1,
            color: AppTheme.infoColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rata-rata ${(totalHours / totalRequests).toStringAsFixed(1)} jam per request',
                      style: TextStyle(
                        color: AppTheme.infoColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (pendingCount > 0)
            Card(
              elevation: 1,
              color: AppTheme.warningColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.notification_important,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$pendingCount request menunggu approval Anda',
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManagerRequestListScreen(),
                          ),
                        );
                      },
                      child: const Text('Lihat'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: List.generate(
            4,
            (index) => Card(
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 24,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    WidgetRef ref,
    DateRangeSelection currentRange,
  ) async {
    final now = DateTime.now();

    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih Periode',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDateRangeOption(
              context,
              ref,
              'Bulan Ini',
              DateTime(now.year, now.month, 1),
              DateTime(now.year, now.month + 1, 0),
            ),
            _buildDateRangeOption(
              context,
              ref,
              'Bulan Lalu',
              DateTime(now.year, now.month - 1, 1),
              DateTime(now.year, now.month, 0),
            ),
            _buildDateRangeOption(
              context,
              ref,
              '3 Bulan Terakhir',
              DateTime(now.year, now.month - 2, 1),
              DateTime(now.year, now.month + 1, 0),
            ),
            _buildDateRangeOption(
              context,
              ref,
              'Tahun Ini',
              DateTime(now.year, 1, 1),
              DateTime(now.year, 12, 31),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(now.year + 1),
                  initialDateRange: DateTimeRange(
                    start: currentRange.startDate,
                    end: currentRange.endDate,
                  ),
                );

                if (picked != null) {
                  ref.read(dashboardDateRangeProvider.notifier).state =
                      DateRangeSelection(
                    startDate: picked.start,
                    endDate: picked.end,
                  );
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Custom Range'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    DateTime start,
    DateTime end,
  ) {
    return ListTile(
      title: Text(label),
      onTap: () {
        ref.read(dashboardDateRangeProvider.notifier).state =
            DateRangeSelection(
          startDate: start,
          endDate: end,
        );
        Navigator.pop(context);
      },
    );
  }
}
