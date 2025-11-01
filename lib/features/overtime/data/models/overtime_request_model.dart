import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/overtime_request_entity.dart';

/// Overtime request model for Firestore serialization
class OvertimeRequestModel extends OvertimeRequestEntity {
  const OvertimeRequestModel({
    required super.id,
    required super.submittedBy,
    required super.submitterName,
    required super.workDate,
    required super.startTime,
    required super.endTime,
    required super.totalHours,
    required super.customerName,
    required super.problemDescription,
    required super.location,
    required super.employeeIds,
    required super.employeeNames,
    required super.workTypes,
    required super.severity,
    super.rootCause,
    super.solution,
    super.notes,
    required super.calculatedEarnings,
    required super.mealAllowance,
    required super.totalEarnings,
    super.status = 'PENDING',
    super.approvedBy,
    super.approverName,
    super.approvedAt,
    super.rejectionReason,
    super.isEdited = false,
    super.editHistory = const [],
    required super.createdAt,
    super.updatedAt,
  });

  /// Create OvertimeRequestModel from OvertimeRequestEntity
  factory OvertimeRequestModel.fromEntity(OvertimeRequestEntity entity) {
    return OvertimeRequestModel(
      id: entity.id,
      submittedBy: entity.submittedBy,
      submitterName: entity.submitterName,
      workDate: entity.workDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      totalHours: entity.totalHours,
      customerName: entity.customerName,
      problemDescription: entity.problemDescription,
      location: entity.location,
      employeeIds: entity.employeeIds,
      employeeNames: entity.employeeNames,
      workTypes: entity.workTypes,
      severity: entity.severity,
      rootCause: entity.rootCause,
      solution: entity.solution,
      notes: entity.notes,
      calculatedEarnings: entity.calculatedEarnings,
      mealAllowance: entity.mealAllowance,
      totalEarnings: entity.totalEarnings,
      status: entity.status,
      approvedBy: entity.approvedBy,
      approverName: entity.approverName,
      approvedAt: entity.approvedAt,
      rejectionReason: entity.rejectionReason,
      isEdited: entity.isEdited,
      editHistory: entity.editHistory,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create OvertimeRequestModel from Firestore document
  factory OvertimeRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OvertimeRequestModel(
      id: doc.id,
      submittedBy: data['submittedBy'] as String,
      submitterName: data['submitterName'] as String,
      workDate: (data['workDate'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      totalHours: (data['totalHours'] as num).toDouble(),
      customerName: data['customerName'] as String,
      problemDescription: data['problemDescription'] as String,
      location: data['location'] as String,
      employeeIds: List<String>.from(data['employeeIds'] as List),
      employeeNames: List<String>.from(data['employeeNames'] as List),
      workTypes: List<String>.from(data['workTypes'] as List),
      severity: data['severity'] as String,
      rootCause: data['rootCause'] as String?,
      solution: data['solution'] as String?,
      notes: data['notes'] as String?,
      calculatedEarnings: (data['calculatedEarnings'] as num).toDouble(),
      mealAllowance: (data['mealAllowance'] as num).toDouble(),
      totalEarnings: (data['totalEarnings'] as num).toDouble(),
      status: data['status'] as String? ?? 'PENDING',
      approvedBy: data['approvedBy'] as String?,
      approverName: data['approverName'] as String?,
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: data['rejectionReason'] as String?,
      isEdited: data['isEdited'] as bool? ?? false,
      editHistory: data['editHistory'] != null
          ? (data['editHistory'] as List)
              .map((e) => EditHistory.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'submittedBy': submittedBy,
      'submitterName': submitterName,
      'workDate': Timestamp.fromDate(workDate),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalHours': totalHours,
      'customerName': customerName,
      'problemDescription': problemDescription,
      'location': location,
      'employeeIds': employeeIds,
      'employeeNames': employeeNames,
      'workTypes': workTypes,
      'severity': severity,
      'rootCause': rootCause,
      'solution': solution,
      'notes': notes,
      'calculatedEarnings': calculatedEarnings,
      'mealAllowance': mealAllowance,
      'totalEarnings': totalEarnings,
      'status': status,
      'approvedBy': approvedBy,
      'approverName': approverName,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectionReason': rejectionReason,
      'isEdited': isEdited,
      'editHistory': editHistory.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Firestore data (without ID)
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Convert to OvertimeRequestEntity
  OvertimeRequestEntity toEntity() {
    return OvertimeRequestEntity(
      id: id,
      submittedBy: submittedBy,
      submitterName: submitterName,
      workDate: workDate,
      startTime: startTime,
      endTime: endTime,
      totalHours: totalHours,
      customerName: customerName,
      problemDescription: problemDescription,
      location: location,
      employeeIds: employeeIds,
      employeeNames: employeeNames,
      workTypes: workTypes,
      severity: severity,
      rootCause: rootCause,
      solution: solution,
      notes: notes,
      calculatedEarnings: calculatedEarnings,
      mealAllowance: mealAllowance,
      totalEarnings: totalEarnings,
      status: status,
      approvedBy: approvedBy,
      approverName: approverName,
      approvedAt: approvedAt,
      rejectionReason: rejectionReason,
      isEdited: isEdited,
      editHistory: editHistory,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
