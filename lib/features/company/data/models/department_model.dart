import '../../domain/entities/department_entity.dart';

class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.id,
    required super.companyId,
    required super.name,
    super.managerId,
    super.employeeCount = 0,
  });

  factory DepartmentModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return DepartmentModel(
      id: docId,
      companyId: json['companyId'] ?? '',
      name: json['name'] ?? '',
      managerId: json['managerId'],
      employeeCount: json['employeeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyId': companyId,
      'name': name,
      'managerId': managerId,
      'employeeCount': employeeCount,
    };
  }
}
