import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/employee_entity.dart';
import '../providers/employee_provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/validators/form_validators.dart';
import '../../../../core/constants/app_constants.dart';

/// Form screen untuk menambah atau edit employee
class EmployeeFormScreen extends ConsumerStatefulWidget {
  final EmployeeEntity? employee; // null = add mode, non-null = edit mode

  const EmployeeFormScreen({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormScreen> createState() =>
      _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _baseRateController = TextEditingController();
  final _weekendRateController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditMode => widget.employee != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _employeeIdController.text = widget.employee!.employeeId;
      _nameController.text = widget.employee!.name;
      _positionController.text = widget.employee!.position;
      _departmentController.text = widget.employee!.department;
      _baseRateController.text = widget.employee!.baseRate.toString();
      _weekendRateController.text = widget.employee!.weekendRate.toString();
    } else {
      // Set default rates
      _baseRateController.text = AppConstants.baseWeekdayRate.toString();
      _weekendRateController.text = AppConstants.baseWeekendRate.toString();
    }
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _baseRateController.dispose();
    _weekendRateController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final employee = EmployeeEntity(
        id: _isEditMode ? widget.employee!.id : '',
        employeeId: _employeeIdController.text.trim(),
        name: _nameController.text.trim(),
        position: _positionController.text.trim(),
        department: _departmentController.text.trim(),
        baseRate: double.parse(_baseRateController.text),
        weekendRate: double.parse(_weekendRateController.text),
        createdAt: _isEditMode ? widget.employee!.createdAt : DateTime.now(),
        updatedAt: _isEditMode ? DateTime.now() : null,
      );

      final controller = ref.read(employeeControllerProvider.notifier);

      bool success;
      if (_isEditMode) {
        success = await controller.updateEmployee(
          widget.employee!.id,
          employee,
        );
      } else {
        final id = await controller.addEmployee(employee);
        success = id != null;
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Data karyawan berhasil diupdate'
                  : 'Karyawan berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final state = ref.read(employeeControllerProvider);
        state.whenOrNull(
          error: (error, stack) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteEmployee() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${widget.employee!.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = ref.read(employeeControllerProvider.notifier);
      final success = await controller.deleteEmployee(widget.employee!.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Karyawan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus karyawan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Karyawan' : 'Tambah Karyawan'),
        actions: _isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isLoading ? null : _deleteEmployee,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Employee ID
            CustomTextField(
              controller: _employeeIdController,
              label: 'ID Karyawan',
              hint: 'Contoh: EMP001',
              prefixIcon: Icons.badge,
              validator: FormValidators.required,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Name
            CustomTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
              prefixIcon: Icons.person,
              validator: FormValidators.required,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Position
            CustomTextField(
              controller: _positionController,
              label: 'Posisi/Jabatan',
              hint: 'Contoh: Technical Support',
              prefixIcon: Icons.work,
              validator: FormValidators.required,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Department
            CustomTextField(
              controller: _departmentController,
              label: 'Departemen',
              hint: 'Contoh: IT Operations',
              prefixIcon: Icons.business,
              validator: FormValidators.required,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),

            // Rate Section Header
            const Text(
              'Rate Lembur per Jam',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Base Rate (Weekday)
            CustomTextField(
              controller: _baseRateController,
              label: 'Rate Hari Biasa (Rp/jam)',
              hint: 'Masukkan rate hari biasa',
              prefixIcon: Icons.monetization_on,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Rate hari biasa harus diisi';
                }
                final rate = double.tryParse(value);
                if (rate == null || rate <= 0) {
                  return 'Rate harus lebih dari 0';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Weekend Rate
            CustomTextField(
              controller: _weekendRateController,
              label: 'Rate Akhir Pekan (Rp/jam)',
              hint: 'Masukkan rate akhir pekan',
              prefixIcon: Icons.monetization_on,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Rate akhir pekan harus diisi';
                }
                final rate = double.tryParse(value);
                if (rate == null || rate <= 0) {
                  return 'Rate harus lebih dari 0';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              onPressed: _isLoading ? null : _saveEmployee,
              text: _isEditMode ? 'Simpan Perubahan' : 'Tambah Karyawan',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
