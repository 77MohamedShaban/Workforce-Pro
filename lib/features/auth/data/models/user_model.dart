import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.companyId,
    super.companyName,
    super.departmentId,
    super.departmentName,
    super.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'employee',
      companyId: json['companyId'],
      companyName: json['companyName'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role,
      'companyId': companyId,
      'companyName': companyName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      role: entity.role,
      companyId: entity.companyId,
      companyName: entity.companyName,
      departmentId: entity.departmentId,
      departmentName: entity.departmentName,
      createdAt: entity.createdAt,
    );
  }
}
