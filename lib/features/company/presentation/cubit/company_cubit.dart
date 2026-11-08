import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity_definition_entity.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/repositories/company_repository.dart';
import 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _repository;

  CompanyCubit(this._repository) : super(CompanyInitial());

  Future<void> loadCompanyData(String companyId) async {
    emit(CompanyLoading());
    try {
      final depts = await _repository.getDepartments(companyId);
      final acts = await _repository.getActivityDefinitions(companyId);
      emit(CompanyLoaded(departments: depts, activities: acts));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> addDepartment(String companyId, String name) async {
    final currentState = state;
    if (currentState is! CompanyLoaded) return;

    try {
      final newDept = await _repository.createDepartment(companyId, name);
      final updatedDepts = List<DepartmentEntity>.from(currentState.departments)..add(newDept);
      emit(CompanyLoaded(departments: updatedDepts, activities: currentState.activities));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> addActivityDefinition(ActivityDefinitionEntity activity) async {
    final currentState = state;
    if (currentState is! CompanyLoaded) return;

    try {
      final newAct = await _repository.createActivityDefinition(activity);
      final updatedActs = List<ActivityDefinitionEntity>.from(currentState.activities)..add(newAct);
      emit(CompanyLoaded(departments: currentState.departments, activities: updatedActs));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }
}
