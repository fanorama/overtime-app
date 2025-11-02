import 'package:flutter/material.dart';
import '../../../employee/domain/entities/employee_entity.dart';
import '../../../../core/constants/app_constants.dart';

/// Dialog untuk memilih karyawan berdasarkan kategori (role)
class EmployeeCategorySelectorDialog extends StatefulWidget {
  final List<EmployeeEntity> allEmployees;
  final Set<String> initialSelected;
  final String category; // 'engineers', 'maintenance', 'postsales'
  final String title;

  const EmployeeCategorySelectorDialog({
    super.key,
    required this.allEmployees,
    required this.initialSelected,
    required this.category,
    required this.title,
  });

  @override
  State<EmployeeCategorySelectorDialog> createState() =>
      _EmployeeCategorySelectorDialogState();
}

class _EmployeeCategorySelectorDialogState
    extends State<EmployeeCategorySelectorDialog> {
  late Set<String> _selected;
  List<EmployeeEntity> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initialSelected);
    _filterEmployeesByCategory();
  }

  void _filterEmployeesByCategory() {
    // Filter employees based on category
    final categoryRole = _getCategoryRole();

    if (categoryRole == null) {
      // If category not mapped, show all employees
      _filteredEmployees = widget.allEmployees;
    } else {
      // Filter by role
      _filteredEmployees = widget.allEmployees
          .where((employee) =>
              employee.position.toLowerCase() == categoryRole.toLowerCase())
          .toList();
    }
  }

  String? _getCategoryRole() {
    switch (widget.category) {
      case 'engineers':
        return AppConstants.employeeRoleEngineer;
      case 'maintenance':
        return AppConstants.employeeRoleMaintenance;
      case 'postsales':
        // Postsales could include both 'postsales' and 'onsite' roles
        return null; // Will be handled specially
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Special handling for postsales category (includes postsales + onsite)
    if (widget.category == 'postsales') {
      _filteredEmployees = widget.allEmployees
          .where((employee) =>
              employee.position.toLowerCase() ==
                  AppConstants.employeeRolePostsales.toLowerCase() ||
              employee.position.toLowerCase() ==
                  AppConstants.employeeRoleOnsite.toLowerCase())
          .toList();
    }

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: _filteredEmployees.isEmpty
            ? const Center(
                child: Text('Belum ada data karyawan untuk kategori ini'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = _filteredEmployees[index];
                  final isSelected = _selected.contains(employee.id);

                  return CheckboxListTile(
                    title: Text(employee.name),
                    subtitle: Text(employee.position),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(employee.id);
                        } else {
                          _selected.remove(employee.id);
                        }
                      });
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

/// Helper function to show the dialog
Future<Set<String>?> showEmployeeCategorySelector({
  required BuildContext context,
  required List<EmployeeEntity> allEmployees,
  required Set<String> initialSelected,
  required String category,
  required String title,
}) async {
  return showDialog<Set<String>>(
    context: context,
    builder: (context) => EmployeeCategorySelectorDialog(
      allEmployees: allEmployees,
      initialSelected: initialSelected,
      category: category,
      title: title,
    ),
  );
}
