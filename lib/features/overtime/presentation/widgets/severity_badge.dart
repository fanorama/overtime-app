import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/extensions/string_extensions.dart';

/// Widget untuk menampilkan severity badge dengan warna
/// NOTE: Uses AppTheme and extension methods for case-insensitive severity comparison
/// to ensure compatibility with any case variations from Firestore
class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({
    super.key,
    required this.severity,
  });

  Color _getSeverityColor() {
    return AppTheme.getSeverityColor(severity);
  }

  IconData _getSeverityIcon() {
    if (severity.isCriticalSeverity) return Icons.error;
    if (severity.isHighSeverity) return Icons.warning;
    if (severity.isMediumSeverity) return Icons.info;
    if (severity.isLowSeverity) return Icons.low_priority;
    return Icons.help_outline; // default for unknown severity
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getSeverityColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeverityColor(),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeverityIcon(),
            size: 14,
            color: _getSeverityColor(),
          ),
          const SizedBox(width: 4),
          Text(
            severity,
            style: TextStyle(
              color: _getSeverityColor(),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
