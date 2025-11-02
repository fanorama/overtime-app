import 'package:flutter/material.dart';
import '../../../../employee/domain/entities/employee_entity.dart';

/// Section 3: Involved People (separated by role)
class OvertimeInvolvedPeopleSection extends StatelessWidget {
  final List<EmployeeEntity> allEmployees;
  final Set<String> selectedEngineers;
  final Set<String> selectedMaintenance;
  final Set<String> selectedPostsales;
  final Function(String category) onSelectEmployees;
  final Function(String employeeId, String category) onRemoveEmployee;

  const OvertimeInvolvedPeopleSection({
    super.key,
    required this.allEmployees,
    required this.selectedEngineers,
    required this.selectedMaintenance,
    required this.selectedPostsales,
    required this.onSelectEmployees,
    required this.onRemoveEmployee,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Karyawan Terlibat'),
        const SizedBox(height: 8),

        // Engineers
        _buildEmployeeCategory(
          context,
          title: 'Engineers',
          category: 'engineers',
          selectedIds: selectedEngineers,
          icon: Icons.engineering,
        ),
        const SizedBox(height: 16),

        // Maintenance
        _buildEmployeeCategory(
          context,
          title: 'Maintenance',
          category: 'maintenance',
          selectedIds: selectedMaintenance,
          icon: Icons.build,
        ),
        const SizedBox(height: 16),

        // Postsales & Onsite
        _buildEmployeeCategory(
          context,
          title: 'Postsales & Onsite',
          category: 'postsales',
          selectedIds: selectedPostsales,
          icon: Icons.support_agent,
        ),
      ],
    );
  }

  Widget _buildEmployeeCategory(
    BuildContext context, {
    required String title,
    required String category,
    required Set<String> selectedIds,
    required IconData icon,
  }) {
    final selectedEmployees = allEmployees
        .where((e) => selectedIds.contains(e.id))
        .toList();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => onSelectEmployees(category),
                  icon: const Icon(Icons.add),
                  label: const Text('Pilih'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            selectedIds.isEmpty
                ? const Text(
                    'Belum ada karyawan dipilih',
                    style: TextStyle(color: Colors.grey),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedEmployees.map((employee) {
                      return Chip(
                        label: Text(employee.name),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => onRemoveEmployee(employee.id, category),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
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
