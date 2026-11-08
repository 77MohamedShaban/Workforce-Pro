import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/activity_definition_entity.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../models/activity_definition_model.dart';
import '../models/department_model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final FirebaseFirestore _firestore;

  CompanyRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<DepartmentEntity>> getDepartments(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionDepartments)
          .where('companyId', isEqualTo: companyId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => DepartmentModel.fromFirestore(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}

    // Seed default departments into Firestore if empty
    final defaults = [
      DepartmentEntity(id: 'dept_001', companyId: companyId, name: 'Engineering', employeeCount: 12),
      DepartmentEntity(id: 'dept_002', companyId: companyId, name: 'Operations', employeeCount: 8),
      DepartmentEntity(id: 'dept_003', companyId: companyId, name: 'Customer Support', employeeCount: 15),
    ];

    for (final d in defaults) {
      final model = DepartmentModel(
        id: d.id,
        companyId: d.companyId,
        name: d.name,
        employeeCount: d.employeeCount,
      );
      try {
        await _firestore
            .collection(AppConstants.collectionDepartments)
            .doc(d.id)
            .set(model.toFirestore());
      } catch (_) {}
    }

    return defaults;
  }

  @override
  Future<DepartmentEntity> createDepartment(String companyId, String name) async {
    final docId = 'dept_${DateTime.now().millisecondsSinceEpoch}';
    final model = DepartmentModel(
      id: docId,
      companyId: companyId,
      name: name,
      employeeCount: 1,
    );

    await _firestore
        .collection(AppConstants.collectionDepartments)
        .doc(docId)
        .set(model.toFirestore());

    return model;
  }

  @override
  Future<List<ActivityDefinitionEntity>> getActivityDefinitions(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionActivities)
          .where('companyId', isEqualTo: companyId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => ActivityDefinitionModel.fromFirestore(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}

    // Seed default activity definitions into Firestore if empty
    final defaults = [
      ActivityDefinitionEntity(id: 'act_def_1', companyId: companyId, name: 'Work Session', code: 'WORK', colorHex: '#3B82F6', iconName: 'work', isPaidBreak: true),
      ActivityDefinitionEntity(id: 'act_def_2', companyId: companyId, name: 'Break', code: 'BREAK', colorHex: '#14B8A6', iconName: 'coffee', isPaidBreak: true),
      ActivityDefinitionEntity(id: 'act_def_3', companyId: companyId, name: 'Lunch', code: 'LUNCH', colorHex: '#F59E0B', iconName: 'restaurant', isPaidBreak: false),
      ActivityDefinitionEntity(id: 'act_def_4', companyId: companyId, name: 'Meeting', code: 'MEETING', colorHex: '#EC4899', iconName: 'groups', isPaidBreak: true),
    ];

    for (final act in defaults) {
      final model = ActivityDefinitionModel(
        id: act.id,
        companyId: act.companyId,
        name: act.name,
        code: act.code,
        colorHex: act.colorHex,
        iconName: act.iconName,
        isPaidBreak: act.isPaidBreak,
      );
      try {
        await _firestore
            .collection(AppConstants.collectionActivities)
            .doc(act.id)
            .set(model.toFirestore());
      } catch (_) {}
    }

    return defaults;
  }

  @override
  Future<ActivityDefinitionEntity> createActivityDefinition(ActivityDefinitionEntity activity) async {
    final model = ActivityDefinitionModel(
      id: activity.id,
      companyId: activity.companyId,
      name: activity.name,
      code: activity.code,
      colorHex: activity.colorHex,
      iconName: activity.iconName,
      isPaidBreak: activity.isPaidBreak,
    );

    await _firestore
        .collection(AppConstants.collectionActivities)
        .doc(activity.id)
        .set(model.toFirestore());

    return model;
  }
}
