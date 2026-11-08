import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final EmployeeRepository _repository;

  EmployeeCubit(this._repository) : super(EmployeeInitial());

  Future<void> loadEmployees(String companyId) async {
    emit(EmployeeLoading());
    try {
      final list = await _repository.getEmployees(companyId);
      emit(EmployeeLoaded(list));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> addEmployee(UserEntity employee) async {
    final currentState = state;
    if (currentState is! EmployeeLoaded) return;

    try {
      final newEmp = await _repository.addEmployee(employee);
      final updatedList = List<UserEntity>.from(currentState.employees)..add(newEmp);
      emit(EmployeeLoaded(updatedList));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
}
