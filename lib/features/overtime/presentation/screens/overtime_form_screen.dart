import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/overtime_request_entity.dart';
import '../../../employee/domain/entities/employee_entity.dart';
import '../../../employee/presentation/providers/employee_provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/validators/form_validators.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/earnings_calculator.dart';

/// Form screen untuk membuat atau edit overtime request
class OvertimeFormScreen extends ConsumerStatefulWidget {
  final OvertimeRequestEntity? overtimeRequest; // null = add mode

  const OvertimeFormScreen({super.key, this.overtimeRequest});

  @override
  ConsumerState<OvertimeFormScreen> createState() =>
      _OvertimeFormScreenState();
}

class _OvertimeFormScreenState extends ConsumerState<OvertimeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _customerNameController = TextEditingController();
  final _problemDescriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.now();

  final Set<String> _selectedEmployeeIds = {};
  final Set<String> _selectedWorkTypes = {};
  String _selectedSeverity = AppConstants.severityMedium;

  bool _isLoading = false;
  bool get _isEditMode => widget.overtimeRequest != null;

  // Calculated earnings
  double _calculatedEarnings = 0.0;
  final double _mealAllowance = AppConstants.mealAllowance;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingData();
    }
    _calculateEarnings();
  }

  void _loadExistingData() {
    final request = widget.overtimeRequest!;
    _customerNameController.text = request.customerName;
    _problemDescriptionController.text = request.problemDescription;
    _locationController.text = request.location;
    _notesController.text = request.notes ?? '';

    _startDate = request.startTime;
    _startTime = TimeOfDay.fromDateTime(request.startTime);
    _endDate = request.endTime;
    _endTime = TimeOfDay.fromDateTime(request.endTime);

    _selectedEmployeeIds.addAll(request.employeeIds);
    _selectedWorkTypes.addAll(request.workTypes);
    _selectedSeverity = request.severity;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _problemDescriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateEarnings() {
    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (_selectedEmployeeIds.isEmpty || _selectedWorkTypes.isEmpty) {
      setState(() {
        _calculatedEarnings = 0;
      });
      return;
    }

    setState(() {
      _calculatedEarnings = EarningsCalculator.calculateTotalEarnings(
        startTime: startDateTime,
        endTime: endDateTime,
        workTypes: _selectedWorkTypes.toList(),
        employeeCount: _selectedEmployeeIds.length,
      );
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2030);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _calculateEarnings();
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? _startTime : _endTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
        _calculateEarnings();
      });
    }
  }

  Future<void> _showEmployeeSelector(List<EmployeeEntity> employees) async {
    final selected = Set<String>.from(_selectedEmployeeIds);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Pilih Karyawan'),
            content: SizedBox(
              width: double.maxFinite,
              child: employees.isEmpty
                  ? const Center(
                      child: Text('Belum ada data karyawan'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        final isSelected = selected.contains(employee.id);

                        return CheckboxListTile(
                          title: Text(employee.name),
                          subtitle: Text(employee.position),
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                selected.add(employee.id);
                              } else {
                                selected.remove(employee.id);
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
                onPressed: () {
                  setState(() {
                    _selectedEmployeeIds.clear();
                    _selectedEmployeeIds.addAll(selected);
                    _calculateEarnings();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmployeeChips(List<EmployeeEntity> employees) {
    if (_selectedEmployeeIds.isEmpty) {
      return const Text(
        'Belum ada karyawan dipilih',
        style: TextStyle(color: Colors.grey),
      );
    }

    final selectedEmployees = employees
        .where((e) => _selectedEmployeeIds.contains(e.id))
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedEmployees.map((employee) {
        return Chip(
          label: Text(employee.name),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () {
            setState(() {
              _selectedEmployeeIds.remove(employee.id);
              _calculateEarnings();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildWorkTypeCheckboxes() {
    final workTypes = [
      AppConstants.workTypeInstallation,
      AppConstants.workTypeRepair,
      AppConstants.workTypePreventive,
      AppConstants.workTypeMonitoring,
      AppConstants.workTypeOther,
    ];

    return Column(
      children: workTypes.map((type) {
        final isSelected = _selectedWorkTypes.contains(type);
        return CheckboxListTile(
          title: Text(type),
          subtitle: Text(
            'Multiplier: ${AppConstants.workTypeMultipliers[type]}x',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedWorkTypes.add(type);
              } else {
                _selectedWorkTypes.remove(type);
              }
              _calculateEarnings();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSeveritySelector() {
    final severities = [
      AppConstants.severityLow,
      AppConstants.severityMedium,
      AppConstants.severityHigh,
      AppConstants.severityCritical,
    ];

    final colors = {
      AppConstants.severityLow: Colors.blue,
      AppConstants.severityMedium: Colors.orange,
      AppConstants.severityHigh: Colors.deepOrange,
      AppConstants.severityCritical: Colors.red,
    };

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Tingkat Keseriusan',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.priority_high),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSeverity,
          isExpanded: true,
          items: severities.map((severity) {
            return DropdownMenuItem(
              value: severity,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[severity],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(severity),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSeverity = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildEarningsPreview() {
    return Card(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimasi Pendapatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upah Lembur:'),
                Text(
                  'Rp ${_calculatedEarnings.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Uang Makan:'),
                Text(
                  'Rp ${_mealAllowance.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp ${(_calculatedEarnings + _mealAllowance).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOvertimeRequest() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field yang wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih minimal 1 karyawan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedWorkTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih minimal 1 jenis pekerjaan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement save to Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur simpan belum diimplementasikan'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Lembur' : 'Tambah Lembur'),
      ),
      body: employeesAsync.when(
        data: (employees) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section 1: Time Information
              _buildSectionHeader('Informasi Waktu'),
              const SizedBox(height: 8),

              // Start Date & Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(_startDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Jam Mulai',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_startTime.format(context)),
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
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Selesai',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(_endDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Jam Selesai',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 2: Customer Information
              _buildSectionHeader('Informasi Pelanggan'),
              const SizedBox(height: 8),

              CustomTextField(
                controller: _customerNameController,
                label: 'Nama Pelanggan',
                hint: 'Masukkan nama pelanggan',
                prefixIcon: Icons.business,
                validator: FormValidators.required,
                maxLength: AppConstants.maxCustomerNameLength,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _problemDescriptionController,
                label: 'Deskripsi Masalah',
                hint: 'Jelaskan masalah yang ditangani',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: FormValidators.required,
                maxLength: AppConstants.maxProblemDescriptionLength,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _locationController,
                label: 'Lokasi',
                hint: 'Masukkan lokasi pekerjaan',
                prefixIcon: Icons.location_on,
                validator: FormValidators.required,
                maxLength: AppConstants.maxLocationLength,
              ),
              const SizedBox(height: 24),

              // Section 3: Work Details
              _buildSectionHeader('Detail Pekerjaan'),
              const SizedBox(height: 8),

              // Employee Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Karyawan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showEmployeeSelector(employees),
                            icon: const Icon(Icons.add),
                            label: const Text('Pilih'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildEmployeeChips(employees),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Work Types
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Pekerjaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildWorkTypeCheckboxes(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Severity
              _buildSeveritySelector(),
              const SizedBox(height: 16),

              // Notes
              CustomTextField(
                controller: _notesController,
                label: 'Catatan (Opsional)',
                hint: 'Tambahkan catatan jika ada',
                prefixIcon: Icons.note,
                maxLines: 3,
                maxLength: AppConstants.maxNotesLength,
              ),
              const SizedBox(height: 24),

              // Earnings Preview
              _buildEarningsPreview(),
              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                onPressed: _isLoading ? null : _saveOvertimeRequest,
                text: _isEditMode ? 'Simpan Perubahan' : 'Submit Lembur',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading employees: $error'),
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
