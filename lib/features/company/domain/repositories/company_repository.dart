import '../entities/activity_definition_entity.dart';
import '../entities/department_entity.dart';

abstract class CompanyRepository {
  Future<List<DepartmentEntity>> getDepartments(String companyId);
  Future<DepartmentEntity> createDepartment(String companyId, String name);
  Future<List<ActivityDefinitionEntity>> getActivityDefinitions(String companyId);
  Future<ActivityDefinitionEntity> createActivityDefinition(ActivityDefinitionEntity activity);
}
