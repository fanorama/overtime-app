import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget untuk menampilkan breakdown severity requests
class SeverityBreakdownWidget extends StatelessWidget {
  final Map<String, int> severityBreakdown;

  const SeverityBreakdownWidget({
    super.key,
    required this.severityBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    final total = severityBreakdown.values.fold<int>(0, (sum, count) => sum + count);

    if (total == 0) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Severity Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Belum ada data',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.priority_high,
                  color: AppTheme.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Severity Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSeverityRow(
              context,
              'CRITICAL',
              severityBreakdown['CRITICAL'] ?? 0,
              total,
              AppTheme.errorColor,
              Icons.warning,
            ),
            const SizedBox(height: 12),
            _buildSeverityRow(
              context,
              'HIGH',
              severityBreakdown['HIGH'] ?? 0,
              total,
              Colors.orange,
              Icons.error_outline,
            ),
            const SizedBox(height: 12),
            _buildSeverityRow(
              context,
              'MEDIUM',
              severityBreakdown['MEDIUM'] ?? 0,
              total,
              AppTheme.warningColor,
              Icons.report_problem_outlined,
            ),
            const SizedBox(height: 12),
            _buildSeverityRow(
              context,
              'LOW',
              severityBreakdown['LOW'] ?? 0,
              total,
              AppTheme.successColor,
              Icons.info_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityRow(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            '$count ($percentage%)',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
