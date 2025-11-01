import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/employee_entity.dart';

/// Employee model for Firestore serialization
class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.id,
    required super.employeeId,
    required super.name,
    required super.position,
    required super.department,
    required super.baseRate,
    required super.weekendRate,
    super.phoneNumber,
    super.isActive = true,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create EmployeeModel from EmployeeEntity
  factory EmployeeModel.fromEntity(EmployeeEntity entity) {
    return EmployeeModel(
      id: entity.id,
      employeeId: entity.employeeId,
      name: entity.name,
      position: entity.position,
      department: entity.department,
      baseRate: entity.baseRate,
      weekendRate: entity.weekendRate,
      phoneNumber: entity.phoneNumber,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create EmployeeModel from Firestore document
  factory EmployeeModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EmployeeModel(
      id: id,
      employeeId: data['employeeId'] as String,
      name: data['name'] as String,
      position: data['position'] as String,
      department: data['department'] as String,
      baseRate: (data['baseRate'] as num).toDouble(),
      weekendRate: (data['weekendRate'] as num).toDouble(),
      phoneNumber: data['phoneNumber'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create EmployeeModel from JSON
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      department: json['department'] as String,
      baseRate: (json['baseRate'] as num).toDouble(),
      weekendRate: (json['weekendRate'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt'] as String))
          : null,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'position': position,
      'department': department,
      'baseRate': baseRate,
      'weekendRate': weekendRate,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Firestore data (without ID)
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Convert to EmployeeEntity
  EmployeeEntity toEntity() {
    return EmployeeEntity(
      id: id,
      employeeId: employeeId,
      name: name,
      position: position,
      department: department,
      baseRate: baseRate,
      weekendRate: weekendRate,
      phoneNumber: phoneNumber,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
