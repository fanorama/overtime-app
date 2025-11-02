import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/overtime_request_entity.dart';

/// Overtime request model for Firestore serialization
class OvertimeRequestModel extends OvertimeRequestEntity {
  const OvertimeRequestModel({
    required super.id,
    required super.submittedBy,
    required super.submitterName,
    required super.startTime,
    required super.endTime,
    required super.totalHours,
    required super.isWeekend,
    required super.customer,
    required super.reportedProblem,
    super.involvedEngineers = const [],
    super.involvedMaintenance = const [],
    super.involvedPostsales = const [],
    required super.typeOfWork,
    required super.product,
    required super.severity,
    required super.workingDescription,
    super.nextPossibleActivity,
    super.version,
    super.pic,
    super.responseTime = 0,
    required super.calculatedEarnings,
    required super.mealAllowance,
    required super.totalEarnings,
    super.status = 'pending',
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
      startTime: entity.startTime,
      endTime: entity.endTime,
      totalHours: entity.totalHours,
      isWeekend: entity.isWeekend,
      customer: entity.customer,
      reportedProblem: entity.reportedProblem,
      involvedEngineers: entity.involvedEngineers,
      involvedMaintenance: entity.involvedMaintenance,
      involvedPostsales: entity.involvedPostsales,
      typeOfWork: entity.typeOfWork,
      product: entity.product,
      severity: entity.severity,
      workingDescription: entity.workingDescription,
      nextPossibleActivity: entity.nextPossibleActivity,
      version: entity.version,
      pic: entity.pic,
      responseTime: entity.responseTime,
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
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      totalHours: (data['totalHours'] as num).toDouble(),
      isWeekend: data['isWeekend'] as bool? ?? false,
      customer: data['customer'] as String,
      reportedProblem: data['reportedProblem'] as String,
      involvedEngineers: data['involvedEngineers'] != null
          ? List<String>.from(data['involvedEngineers'] as List)
          : [],
      involvedMaintenance: data['involvedMaintenance'] != null
          ? List<String>.from(data['involvedMaintenance'] as List)
          : [],
      involvedPostsales: data['involvedPostsales'] != null
          ? List<String>.from(data['involvedPostsales'] as List)
          : [],
      typeOfWork: List<String>.from(data['typeOfWork'] as List),
      product: data['product'] as String,
      severity: data['severity'] as String,
      workingDescription: data['workingDescription'] as String,
      nextPossibleActivity: data['nextPossibleActivity'] as String?,
      version: data['version'] as String?,
      pic: data['pic'] as String?,
      responseTime: data['responseTime'] as int? ?? 0,
      calculatedEarnings: (data['calculatedEarnings'] as num).toDouble(),
      mealAllowance: (data['mealAllowance'] as num).toDouble(),
      totalEarnings: (data['totalEarnings'] as num).toDouble(),
      status: data['status'] as String? ?? 'pending',
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
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalHours': totalHours,
      'isWeekend': isWeekend,
      'customer': customer,
      'reportedProblem': reportedProblem,
      'involvedEngineers': involvedEngineers,
      'involvedMaintenance': involvedMaintenance,
      'involvedPostsales': involvedPostsales,
      'typeOfWork': typeOfWork,
      'product': product,
      'severity': severity,
      'workingDescription': workingDescription,
      'nextPossibleActivity': nextPossibleActivity,
      'version': version,
      'pic': pic,
      'responseTime': responseTime,
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
      startTime: startTime,
      endTime: endTime,
      totalHours: totalHours,
      isWeekend: isWeekend,
      customer: customer,
      reportedProblem: reportedProblem,
      involvedEngineers: involvedEngineers,
      involvedMaintenance: involvedMaintenance,
      involvedPostsales: involvedPostsales,
      typeOfWork: typeOfWork,
      product: product,
      severity: severity,
      workingDescription: workingDescription,
      nextPossibleActivity: nextPossibleActivity,
      version: version,
      pic: pic,
      responseTime: responseTime,
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
