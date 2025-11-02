import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget untuk menampilkan breakdown status requests
class StatusBreakdownWidget extends StatelessWidget {
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  const StatusBreakdownWidget({
    super.key,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = pendingCount + approvedCount + rejectedCount;

    if (total == 0) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status Breakdown',
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
            Text(
              'Status Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              context,
              'Pending',
              pendingCount,
              total,
              AppTheme.warningColor,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              context,
              'Approved',
              approvedCount,
              total,
              AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              context,
              'Rejected',
              rejectedCount,
              total,
              AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = (count / total * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: count / total,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
