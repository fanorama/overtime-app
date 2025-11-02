/// Overtime request entity - Updated to match design schema
class OvertimeRequestEntity {
  final String id;
  final String submittedBy; // User ID
  final String submitterName; // Denormalized for query performance

  // Time & Duration
  final DateTime startTime;
  final DateTime endTime;
  final double totalHours;
  final bool isWeekend;

  // Customer & Problem
  final String customer;
  final String reportedProblem;

  // Involved People (separated by role)
  final List<String> involvedEngineers;
  final List<String> involvedMaintenance;
  final List<String> involvedPostsales;

  // Work Details
  final List<String> typeOfWork;
  final String product;
  final String severity; // low, medium, high, critical

  // Work Description & Follow-up
  final String workingDescription;
  final String? nextPossibleActivity;
  final String? version;
  final String? pic;
  final int responseTime; // in minutes

  // Earnings
  final double calculatedEarnings;
  final double mealAllowance;
  final double totalEarnings;

  // Approval workflow
  final String status; // pending, approved, rejected
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
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.isWeekend,
    required this.customer,
    required this.reportedProblem,
    this.involvedEngineers = const [],
    this.involvedMaintenance = const [],
    this.involvedPostsales = const [],
    required this.typeOfWork,
    required this.product,
    required this.severity,
    required this.workingDescription,
    this.nextPossibleActivity,
    this.version,
    this.pic,
    this.responseTime = 0,
    required this.calculatedEarnings,
    required this.mealAllowance,
    required this.totalEarnings,
    this.status = 'pending',
    this.approvedBy,
    this.approverName,
    this.approvedAt,
    this.rejectionReason,
    this.isEdited = false,
    this.editHistory = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  // Helper getter to get all involved employees
  List<String> get allInvolvedEmployees => [
        ...involvedEngineers,
        ...involvedMaintenance,
        ...involvedPostsales,
      ];

  OvertimeRequestEntity copyWith({
    String? id,
    String? submittedBy,
    String? submitterName,
    DateTime? startTime,
    DateTime? endTime,
    double? totalHours,
    bool? isWeekend,
    String? customer,
    String? reportedProblem,
    List<String>? involvedEngineers,
    List<String>? involvedMaintenance,
    List<String>? involvedPostsales,
    List<String>? typeOfWork,
    String? product,
    String? severity,
    String? workingDescription,
    String? nextPossibleActivity,
    String? version,
    String? pic,
    int? responseTime,
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
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalHours: totalHours ?? this.totalHours,
      isWeekend: isWeekend ?? this.isWeekend,
      customer: customer ?? this.customer,
      reportedProblem: reportedProblem ?? this.reportedProblem,
      involvedEngineers: involvedEngineers ?? this.involvedEngineers,
      involvedMaintenance: involvedMaintenance ?? this.involvedMaintenance,
      involvedPostsales: involvedPostsales ?? this.involvedPostsales,
      typeOfWork: typeOfWork ?? this.typeOfWork,
      product: product ?? this.product,
      severity: severity ?? this.severity,
      workingDescription: workingDescription ?? this.workingDescription,
      nextPossibleActivity: nextPossibleActivity ?? this.nextPossibleActivity,
      version: version ?? this.version,
      pic: pic ?? this.pic,
      responseTime: responseTime ?? this.responseTime,
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
