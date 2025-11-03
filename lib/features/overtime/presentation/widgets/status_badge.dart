import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Widget untuk menampilkan status badge dengan warna
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isEdited;

  const StatusBadge({
    super.key,
    required this.status,
    this.isEdited = false,
  });

  Color _getStatusColor() {
    switch (status) {
      case AppConstants.statusApproved:
        return Colors.green;
      case AppConstants.statusRejected:
        return Colors.red;
      case AppConstants.statusPending:
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case AppConstants.statusApproved:
        return Icons.check_circle;
      case AppConstants.statusRejected:
        return Icons.cancel;
      case AppConstants.statusPending:
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                size: 16,
                color: _getStatusColor(),
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (isEdited) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue,
                width: 1,
              ),
            ),
            child: const Text(
              'EDITED',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
