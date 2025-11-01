/// Employee entity for master data
class EmployeeEntity {
  final String id;
  final String employeeId; // Employee ID (e.g., EMP001)
  final String name;
  final String position;
  final String department;
  final double baseRate; // Weekday hourly rate
  final double weekendRate; // Weekend hourly rate
  final String? phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EmployeeEntity({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.position,
    required this.department,
    required this.baseRate,
    required this.weekendRate,
    this.phoneNumber,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  EmployeeEntity copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? position,
    String? department,
    double? baseRate,
    double? weekendRate,
    String? phoneNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      baseRate: baseRate ?? this.baseRate,
      weekendRate: weekendRate ?? this.weekendRate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmployeeEntity &&
        other.id == id &&
        other.employeeId == employeeId &&
        other.name == name &&
        other.position == position &&
        other.department == department &&
        other.baseRate == baseRate &&
        other.weekendRate == weekendRate &&
        other.phoneNumber == phoneNumber &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        name.hashCode ^
        position.hashCode ^
        department.hashCode ^
        baseRate.hashCode ^
        weekendRate.hashCode ^
        phoneNumber.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
