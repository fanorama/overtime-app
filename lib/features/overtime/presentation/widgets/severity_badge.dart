import 'package:flutter/material.dart';

/// Widget untuk menampilkan severity badge dengan warna
class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({
    super.key,
    required this.severity,
  });

  Color _getSeverityColor() {
    switch (severity) {
      case 'CRITICAL':
        return Colors.red.shade700;
      case 'HIGH':
        return Colors.orange.shade700;
      case 'MEDIUM':
        return Colors.yellow.shade700;
      case 'LOW':
      default:
        return Colors.blue.shade700;
    }
  }

  IconData _getSeverityIcon() {
    switch (severity) {
      case 'CRITICAL':
        return Icons.error;
      case 'HIGH':
        return Icons.warning;
      case 'MEDIUM':
        return Icons.info;
      case 'LOW':
      default:
        return Icons.low_priority;
    }
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
