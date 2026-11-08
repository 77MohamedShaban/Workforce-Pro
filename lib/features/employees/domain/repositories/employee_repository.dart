import '../../../auth/domain/entities/user_entity.dart';

abstract class EmployeeRepository {
  Future<List<UserEntity>> getEmployees(String companyId);
  Future<UserEntity> addEmployee(UserEntity employee);
}
