import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<UserEntity>> getEmployees(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionUsers)
          .where('companyId', isEqualTo: companyId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}

    // Seed default employee users into Firestore if empty
    final defaults = [
      UserEntity(id: 'emp_001', email: 'john@workforce.com', fullName: 'John Doe', role: AppConstants.roleEmployee, companyId: companyId, companyName: 'Workforce Pro Ltd.', departmentName: 'Engineering'),
      UserEntity(id: 'emp_002', email: 'sarah@workforce.com', fullName: 'Sarah Smith', role: AppConstants.roleEmployee, companyId: companyId, companyName: 'Workforce Pro Ltd.', departmentName: 'Operations'),
      UserEntity(id: 'emp_003', email: 'michael@workforce.com', fullName: 'Michael Brown', role: AppConstants.roleManager, companyId: companyId, companyName: 'Workforce Pro Ltd.', departmentName: 'Engineering'),
    ];

    for (final emp in defaults) {
      final model = UserModel.fromEntity(emp);
      try {
        await _firestore
            .collection(AppConstants.collectionUsers)
            .doc(emp.id)
            .set(model.toFirestore());
      } catch (_) {}
    }

    return defaults;
  }

  @override
  Future<UserEntity> addEmployee(UserEntity employee) async {
    final model = UserModel.fromEntity(employee);

    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(employee.id)
        .set(model.toFirestore());

    return employee;
  }
}
