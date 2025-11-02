import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Section 1: Time & Duration
class OvertimeTimeSection extends StatelessWidget {
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime endDate;
  final TimeOfDay endTime;
  final double calculatedHours;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndDate;
  final VoidCallback onSelectEndTime;

  const OvertimeTimeSection({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.calculatedHours,
    required this.onSelectStartDate,
    required this.onSelectStartTime,
    required this.onSelectEndDate,
    required this.onSelectEndTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Informasi Waktu'),
        const SizedBox(height: 8),

        // Start Date & Time
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onSelectStartDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Mulai',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(startDate),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: onSelectStartTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Jam Mulai',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(startTime.format(context)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // End Date & Time
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onSelectEndDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Selesai',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(endDate),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: onSelectEndTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Jam Selesai',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(endTime.format(context)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Calculated Hours (Display Only)
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Total Jam Kerja',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.timer),
          ),
          child: Text(
            '${calculatedHours.toStringAsFixed(1)} jam',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
