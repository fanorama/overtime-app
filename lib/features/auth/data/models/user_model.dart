import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// User model for Firestore serialization
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.role,
    super.displayName,
    required super.createdAt,
  });

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      role: entity.role,
      displayName: entity.displayName,
      createdAt: entity.createdAt,
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] as String,
      role: data['role'] as String,
      displayName: data['displayName'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      displayName: json['displayName'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to Firestore data (without ID)
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Convert to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      role: role,
      displayName: displayName,
      createdAt: createdAt,
    );
  }
}
