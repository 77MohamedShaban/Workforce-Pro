import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'manager' or 'employee'
  final String? companyId;
  final String? companyName;
  final String? departmentId;
  final String? departmentName;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.companyId,
    this.companyName,
    this.departmentId,
    this.departmentName,
    this.createdAt,
  });

  bool get isManager => role == 'manager';

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? companyId,
    String? companyName,
    String? departmentId,
    String? departmentName,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        role,
        companyId,
        companyName,
        departmentId,
        departmentName,
        createdAt,
      ];
}
