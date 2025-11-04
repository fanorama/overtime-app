import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/overtime_request_entity.dart';
import '../../../employee/domain/entities/employee_entity.dart';
import '../../../employee/presentation/providers/employee_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/overtime_provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/earnings_calculator.dart';
import '../../../../core/extensions/text_editing_controller_extension.dart';
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

  bool _isSaving = false; // Changed from final _isLoading to mutable _isSaving
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
    // Prevent double-tap
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field yang wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ FIX Bug #5: Validate field length AFTER sanitization
    // Check critical fields that Firestore rules require minimum length
    final sanitizedReportedProblem = _reportedProblemController.sanitizedMultilineText;
    final sanitizedWorkingDescription = _workingDescriptionController.sanitizedMultilineText;

    if (sanitizedReportedProblem.length < AppConstants.minReportedProblemLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deskripsi masalah terlalu pendek setelah dibersihkan. Minimal ${AppConstants.minReportedProblemLength} karakter bermakna.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (sanitizedWorkingDescription.length < AppConstants.minWorkingDescriptionLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deskripsi pekerjaan terlalu pendek setelah dibersihkan. Minimal ${AppConstants.minWorkingDescriptionLength} karakter bermakna.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set loading state
    setState(() => _isSaving = true);

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

    // Check if editing approved/rejected request and show warning
    if (_isEditMode && widget.overtimeRequest!.status != AppConstants.statusPending) {
      final shouldProceed = await _showEditApprovedWarning(widget.overtimeRequest!.status);
      if (shouldProceed != true) return;
    }

    // Check if widget is still mounted after async operation
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build datetime objects
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

    // Calculate earnings
    final totalHours = _calculatedHours;
    final isWeekend = startDateTime.weekday == DateTime.saturday ||
        startDateTime.weekday == DateTime.sunday;
    final earnings = EarningsCalculator.calculateTotalEarnings(
      startTime: startDateTime,
      endTime: endDateTime,
      workTypes: _selectedWorkTypes.toList(),
      employeeCount: totalEmployees,
    );

    // Determine if this is a re-submission (editing approved/rejected request)
    final isResubmission = _isEditMode && widget.overtimeRequest!.status != AppConstants.statusPending;

    // Create or update request entity
    // SECURITY: All text inputs are sanitized using extension method
    final request = OvertimeRequestEntity(
      id: _isEditMode ? widget.overtimeRequest!.id : '',
      submittedBy: authState.user!.id,
      submitterName: authState.user!.displayName ?? authState.user!.username,
      startTime: startDateTime,
      endTime: endDateTime,
      totalHours: totalHours,
      isWeekend: isWeekend,
      customer: _customerController.sanitizedText,
      reportedProblem: _reportedProblemController.sanitizedMultilineText,
      involvedEngineers: _selectedEngineers.toList(),
      involvedMaintenance: _selectedMaintenance.toList(),
      involvedPostsales: _selectedPostsales.toList(),
      typeOfWork: _selectedWorkTypes.toList(),
      product: _productController.sanitizedText,
      severity: _selectedSeverity,
      workingDescription: _workingDescriptionController.sanitizedMultilineText,
      nextPossibleActivity: _nextActivityController.text.trim().isEmpty
          ? null
          : _nextActivityController.sanitizedMultilineText,
      version: _versionController.text.trim().isEmpty
          ? null
          : _versionController.sanitizedText,
      pic: _picController.text.trim().isEmpty
          ? null
          : _picController.sanitizedText,
      responseTime: int.tryParse(_responseTimeController.text) ?? 0,
      calculatedEarnings: earnings,
      mealAllowance: _mealAllowance,
      totalEarnings: earnings + _mealAllowance,
      status: isResubmission
          ? AppConstants.statusPending // Reset to pending if editing approved/rejected
          : (_isEditMode ? widget.overtimeRequest!.status : AppConstants.statusPending),
      // ✅ FIX Bug #2: Clear approval fields when re-submitting
      approvedBy: isResubmission ? null : (_isEditMode ? widget.overtimeRequest!.approvedBy : null),
      approverName: isResubmission ? null : (_isEditMode ? widget.overtimeRequest!.approverName : null),
      approvedAt: isResubmission ? null : (_isEditMode ? widget.overtimeRequest!.approvedAt : null),
      rejectionReason: isResubmission ? null : (_isEditMode ? widget.overtimeRequest!.rejectionReason : null),
      isEdited: isResubmission,
      editHistory: isResubmission
          ? [
              ...widget.overtimeRequest!.editHistory,
              EditHistory(
                editedAt: DateTime.now(),
                editedBy: authState.user!.displayName ?? authState.user!.username,
                reason: 'Request edited, requiring re-approval',
              ),
            ]
          : (_isEditMode ? widget.overtimeRequest!.editHistory : []),
      createdAt: _isEditMode ? widget.overtimeRequest!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to Firestore
    final controller = ref.read(overtimeControllerProvider.notifier);
    bool success;
    String? errorMessage;

    if (_isEditMode) {
      success = await controller.updateRequest(widget.overtimeRequest!.id, request);
    } else {
      final id = await controller.createRequest(request);
      success = id != null;
    }

    // ✅ FIX Bug #3: Get detailed error message from controller state
    if (!success) {
      final controllerState = ref.read(overtimeControllerProvider);
      controllerState.whenOrNull(
        error: (error, stack) {
          errorMessage = error.toString();
          // Extract meaningful error message if possible
          if (errorMessage!.contains('permission-denied')) {
            errorMessage = 'Tidak memiliki izin untuk operasi ini';
          } else if (errorMessage!.contains('Failed to')) {
            // Extract message after "Exception: Failed to..."
            final match = RegExp(r'Failed to [^:]+: (.+)').firstMatch(errorMessage!);
            if (match != null) {
              errorMessage = match.group(1);
            }
          }
        },
      );
    }

    if (!mounted) return;

    // Clear loading state
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Request berhasil diupdate' : 'Request berhasil disubmit'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      // Show detailed error message
      final displayError = errorMessage ?? (_isEditMode ? 'Gagal update request' : 'Gagal submit request');
      print('🔴 [FORM] Displaying error to user: $displayError');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5), // Longer duration for error messages
        ),
      );
    }
  }

  /// Show warning dialog when editing approved/rejected request
  Future<bool?> _showEditApprovedWarning(String currentStatus) async {
    final statusText = currentStatus == AppConstants.statusApproved ? 'disetujui' : 'ditolak';
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Perhatian'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request ini sudah $statusText.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Jika Anda melakukan perubahan:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Status akan kembali ke PENDING\n'
              '• Memerlukan approval ulang dari manager\n'
              '• Perubahan akan dicatat dalam history',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Apakah Anda yakin ingin melanjutkan?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lanjutkan Edit'),
          ),
        ],
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
                onPressed: _isSaving ? null : _saveOvertimeRequest,
                text: _isEditMode ? 'Simpan Perubahan' : 'Submit Lembur',
                isLoading: _isSaving,
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
