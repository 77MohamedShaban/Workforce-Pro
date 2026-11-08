import 'package:equatable/equatable.dart';

class DepartmentEntity extends Equatable {
  final String id;
  final String companyId;
  final String name;
  final String? managerId;
  final int employeeCount;

  const DepartmentEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.managerId,
    this.employeeCount = 0,
  });

  @override
  List<Object?> get props => [id, companyId, name, managerId, employeeCount];
}
