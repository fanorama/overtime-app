/// User entity representing authenticated user
class UserEntity {
  final String id;
  final String username;
  final String role; // 'employee' or 'manager'
  final String? displayName;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.role,
    this.displayName,
    required this.createdAt,
  });

  bool get isManager => role == 'manager';
  bool get isEmployee => role == 'employee';

  UserEntity copyWith({
    String? id,
    String? username,
    String? role,
    String? displayName,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.username == username &&
        other.role == role &&
        other.displayName == displayName &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        role.hashCode ^
        displayName.hashCode ^
        createdAt.hashCode;
  }
}
