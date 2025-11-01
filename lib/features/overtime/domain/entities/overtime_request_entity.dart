/// Overtime request entity
class OvertimeRequestEntity {
  final String id;
  final String submittedBy; // User ID
  final String submitterName; // Denormalized for query performance

  // Time & Customer Info
  final DateTime workDate;
  final DateTime startTime;
  final DateTime endTime;
  final double totalHours;
  final String customerName;
  final String problemDescription;
  final String location;

  // People involved
  final List<String> employeeIds;
  final List<String> employeeNames; // Denormalized

  // Work details
  final List<String> workTypes;
  final String severity; // Low, Medium, High, Critical
  final String? rootCause;
  final String? solution;
  final String? notes;

  // Earnings
  final double calculatedEarnings;
  final double mealAllowance;
  final double totalEarnings;

  // Approval workflow
  final String status; // PENDING, APPROVED, REJECTED
  final String? approvedBy; // Manager User ID
  final String? approverName;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final bool isEdited;
  final List<EditHistory> editHistory;

  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OvertimeRequestEntity({
    required this.id,
    required this.submittedBy,
    required this.submitterName,
    required this.workDate,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.customerName,
    required this.problemDescription,
    required this.location,
    required this.employeeIds,
    required this.employeeNames,
    required this.workTypes,
    required this.severity,
    this.rootCause,
    this.solution,
    this.notes,
    required this.calculatedEarnings,
    required this.mealAllowance,
    required this.totalEarnings,
    this.status = 'PENDING',
    this.approvedBy,
    this.approverName,
    this.approvedAt,
    this.rejectionReason,
    this.isEdited = false,
    this.editHistory = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isWeekend => workDate.weekday == DateTime.saturday ||
                        workDate.weekday == DateTime.sunday;

  OvertimeRequestEntity copyWith({
    String? id,
    String? submittedBy,
    String? submitterName,
    DateTime? workDate,
    DateTime? startTime,
    DateTime? endTime,
    double? totalHours,
    String? customerName,
    String? problemDescription,
    String? location,
    List<String>? employeeIds,
    List<String>? employeeNames,
    List<String>? workTypes,
    String? severity,
    String? rootCause,
    String? solution,
    String? notes,
    double? calculatedEarnings,
    double? mealAllowance,
    double? totalEarnings,
    String? status,
    String? approvedBy,
    String? approverName,
    DateTime? approvedAt,
    String? rejectionReason,
    bool? isEdited,
    List<EditHistory>? editHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OvertimeRequestEntity(
      id: id ?? this.id,
      submittedBy: submittedBy ?? this.submittedBy,
      submitterName: submitterName ?? this.submitterName,
      workDate: workDate ?? this.workDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalHours: totalHours ?? this.totalHours,
      customerName: customerName ?? this.customerName,
      problemDescription: problemDescription ?? this.problemDescription,
      location: location ?? this.location,
      employeeIds: employeeIds ?? this.employeeIds,
      employeeNames: employeeNames ?? this.employeeNames,
      workTypes: workTypes ?? this.workTypes,
      severity: severity ?? this.severity,
      rootCause: rootCause ?? this.rootCause,
      solution: solution ?? this.solution,
      notes: notes ?? this.notes,
      calculatedEarnings: calculatedEarnings ?? this.calculatedEarnings,
      mealAllowance: mealAllowance ?? this.mealAllowance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approverName: approverName ?? this.approverName,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isEdited: isEdited ?? this.isEdited,
      editHistory: editHistory ?? this.editHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Edit history for tracking changes
class EditHistory {
  final DateTime editedAt;
  final String editedBy;
  final String? reason;

  const EditHistory({
    required this.editedAt,
    required this.editedBy,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'editedAt': editedAt.toIso8601String(),
      'editedBy': editedBy,
      'reason': reason,
    };
  }

  factory EditHistory.fromJson(Map<String, dynamic> json) {
    return EditHistory(
      editedAt: DateTime.parse(json['editedAt'] as String),
      editedBy: json['editedBy'] as String,
      reason: json['reason'] as String?,
    );
  }
}
