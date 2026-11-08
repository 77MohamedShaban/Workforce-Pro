import 'package:equatable/equatable.dart';
import '../../domain/entities/activity_definition_entity.dart';
import '../../domain/entities/department_entity.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final List<DepartmentEntity> departments;
  final List<ActivityDefinitionEntity> activities;

  const CompanyLoaded({
    this.departments = const [],
    this.activities = const [],
  });

  @override
  List<Object?> get props => [departments, activities];
}

class CompanyError extends CompanyState {
  final String message;

  const CompanyError(this.message);

  @override
  List<Object?> get props => [message];
}
