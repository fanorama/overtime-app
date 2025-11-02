import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/overtime_request_entity.dart';
import '../../../employee/domain/entities/employee_entity.dart';
import '../../../employee/presentation/providers/employee_provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/earnings_calculator.dart';
import '../widgets/sections/overtime_time_section.dart';
import '../widgets/sections/overtime_customer_section.dart';
import '../widgets/sections/overtime_involved_people_section.dart';
import '../widgets/sections/overtime_work_details_section.dart';
import '../widgets/sections/overtime_work_description_section.dart';
import '../widgets/sections/overtime_earnings_preview.dart';
import '../widgets/employee_category_selector_dialog.dart';

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
  final _customerController = TextEditingController();
  final _reportedProblemController = TextEditingController();
  final _productController = TextEditingController();
  final _workingDescriptionController = TextEditingController();
  final _nextActivityController = TextEditingController();
  final _versionController = TextEditingController();
  final _picController = TextEditingController();
  final _responseTimeController = TextEditingController();

  // Form state
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.now();

  // Employee selections by category
  final Set<String> _selectedEngineers = {};
  final Set<String> _selectedMaintenance = {};
  final Set<String> _selectedPostsales = {};

  final Set<String> _selectedWorkTypes = {};
  String _selectedSeverity = AppConstants.severityMedium;

  final bool _isLoading = false;
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

    // Customer & Problem
    _customerController.text = request.customer;
    _reportedProblemController.text = request.reportedProblem;

    // Time
    _startDate = request.startTime;
    _startTime = TimeOfDay.fromDateTime(request.startTime);
    _endDate = request.endTime;
    _endTime = TimeOfDay.fromDateTime(request.endTime);

    // Involved People
    _selectedEngineers.addAll(request.involvedEngineers);
    _selectedMaintenance.addAll(request.involvedMaintenance);
    _selectedPostsales.addAll(request.involvedPostsales);

    // Work Details
    _selectedWorkTypes.addAll(request.typeOfWork);
    _productController.text = request.product;
    _selectedSeverity = request.severity;

    // Work Description & Follow-up
    _workingDescriptionController.text = request.workingDescription;
    _nextActivityController.text = request.nextPossibleActivity ?? '';
    _versionController.text = request.version ?? '';
    _picController.text = request.pic ?? '';
    _responseTimeController.text = request.responseTime.toString();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _reportedProblemController.dispose();
    _productController.dispose();
    _workingDescriptionController.dispose();
    _nextActivityController.dispose();
    _versionController.dispose();
    _picController.dispose();
    _responseTimeController.dispose();
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

    // Calculate total employees from all 3 categories
    final totalEmployees = _selectedEngineers.length +
        _selectedMaintenance.length +
        _selectedPostsales.length;

    if (totalEmployees == 0 || _selectedWorkTypes.isEmpty) {
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
        employeeCount: totalEmployees,
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

  Future<void> _showEmployeeCategorySelector(
    List<EmployeeEntity> employees,
    String category,
  ) async {
    final titles = {
      'engineers': 'Pilih Engineers',
      'maintenance': 'Pilih Maintenance',
      'postsales': 'Pilih Postsales & Onsite',
    };

    final initialSelected = category == 'engineers'
        ? _selectedEngineers
        : category == 'maintenance'
            ? _selectedMaintenance
            : _selectedPostsales;

    final result = await showEmployeeCategorySelector(
      context: context,
      allEmployees: employees,
      initialSelected: initialSelected,
      category: category,
      title: titles[category] ?? 'Pilih Karyawan',
    );

    if (result != null) {
      setState(() {
        if (category == 'engineers') {
          _selectedEngineers.clear();
          _selectedEngineers.addAll(result);
        } else if (category == 'maintenance') {
          _selectedMaintenance.clear();
          _selectedMaintenance.addAll(result);
        } else if (category == 'postsales') {
          _selectedPostsales.clear();
          _selectedPostsales.addAll(result);
        }
        _calculateEarnings();
      });
    }
  }

  void _removeEmployee(String employeeId, String category) {
    setState(() {
      if (category == 'engineers') {
        _selectedEngineers.remove(employeeId);
      } else if (category == 'maintenance') {
        _selectedMaintenance.remove(employeeId);
      } else if (category == 'postsales') {
        _selectedPostsales.remove(employeeId);
      }
      _calculateEarnings();
    });
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

    // Validate total employees from all 3 categories
    final totalEmployees = _selectedEngineers.length +
        _selectedMaintenance.length +
        _selectedPostsales.length;

    if (totalEmployees == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih minimal 1 karyawan dari kategori manapun'),
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

    // TODO: Implement save to Firestore with new schema
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur simpan belum diimplementasikan'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  double get _calculatedHours {
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
    return endDateTime.difference(startDateTime).inMinutes / 60.0;
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
              // Section 1: Time & Duration
              OvertimeTimeSection(
                startDate: _startDate,
                startTime: _startTime,
                endDate: _endDate,
                endTime: _endTime,
                calculatedHours: _calculatedHours,
                onSelectStartDate: () => _selectDate(context, true),
                onSelectStartTime: () => _selectTime(context, true),
                onSelectEndDate: () => _selectDate(context, false),
                onSelectEndTime: () => _selectTime(context, false),
              ),
              const SizedBox(height: 24),

              // Section 2: Customer & Problem
              OvertimeCustomerSection(
                customerController: _customerController,
                reportedProblemController: _reportedProblemController,
              ),
              const SizedBox(height: 24),

              // Section 3: Involved People
              OvertimeInvolvedPeopleSection(
                allEmployees: employees,
                selectedEngineers: _selectedEngineers,
                selectedMaintenance: _selectedMaintenance,
                selectedPostsales: _selectedPostsales,
                onSelectEmployees: (category) =>
                    _showEmployeeCategorySelector(employees, category),
                onRemoveEmployee: _removeEmployee,
              ),
              const SizedBox(height: 24),

              // Section 4: Work Details
              OvertimeWorkDetailsSection(
                selectedWorkTypes: _selectedWorkTypes,
                productController: _productController,
                selectedSeverity: _selectedSeverity,
                onWorkTypeChanged: (type) {
                  setState(() {
                    if (_selectedWorkTypes.contains(type)) {
                      _selectedWorkTypes.remove(type);
                    } else {
                      _selectedWorkTypes.add(type);
                    }
                    _calculateEarnings();
                  });
                },
                onSeverityChanged: (severity) {
                  setState(() {
                    _selectedSeverity = severity;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Section 5: Work Description & Follow-up
              OvertimeWorkDescriptionSection(
                workingDescriptionController: _workingDescriptionController,
                nextActivityController: _nextActivityController,
                versionController: _versionController,
                picController: _picController,
                responseTimeController: _responseTimeController,
              ),
              const SizedBox(height: 24),

              // Section 6: Earnings Preview
              OvertimeEarningsPreview(
                calculatedEarnings: _calculatedEarnings,
                mealAllowance: _mealAllowance,
              ),
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
}
