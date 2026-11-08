import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/actual_activity_transition_entity.dart';
import '../../domain/entities/planned_activity_entity.dart';
import '../../domain/entities/planned_schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../models/actual_activity_transition_model.dart';
import '../models/planned_schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final FirebaseFirestore _firestore;

  ScheduleRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PlannedScheduleEntity?> getScheduleForEmployee(String employeeId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final canonicalDocId = 'sched_${employeeId}_${startOfDay.millisecondsSinceEpoch}';

    try {
      // 1. Check direct canonical document ID for this employee and date
      final directDoc = await _firestore
          .collection(AppConstants.collectionSchedules)
          .doc(canonicalDocId)
          .get();

      if (directDoc.exists && directDoc.data() != null) {
        return PlannedScheduleModel.fromFirestore(
          directDoc.data()!,
          directDoc.id,
        );
      }

      // 2. Fetch all schedules in Firestore for the company / collection to find matching employeeId
      final snapshot = await _firestore
          .collection(AppConstants.collectionSchedules)
          .get();

      final matches = snapshot.docs.where((doc) {
        final data = doc.data();
        final matchEmpId = data['employeeId'] == employeeId;
        bool matchDate = false;
        if (data['date'] is Timestamp) {
          final d = (data['date'] as Timestamp).toDate();
          matchDate = d.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              d.isBefore(endOfDay.add(const Duration(seconds: 1)));
        }
        return matchEmpId && matchDate;
      }).toList();

      if (matches.isNotEmpty) {
        return PlannedScheduleModel.fromFirestore(
          matches.last.data(),
          matches.last.id,
        );
      }
    } catch (_) {}

    // Fetch real employee name from Firestore users collection
    String realUserName = 'Employee';
    try {
      final userDoc = await _firestore.collection(AppConstants.collectionUsers).doc(employeeId).get();
      if (userDoc.exists && userDoc.data() != null) {
        realUserName = userDoc.data()!['fullName'] ?? 'Employee';
      }
    } catch (_) {}

    // Seed initial schedule into Firestore for this employee & date with their REAL name
    final newSchedule = _createInitialSchedule(employeeId, realUserName, startOfDay);
    try {
      await saveSchedule(newSchedule);
    } catch (_) {}
    return newSchedule;
  }

  @override
  Future<List<PlannedScheduleEntity>> getCompanySchedules(String companyId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionSchedules)
          .get();

      final matches = snapshot.docs.where((doc) {
        final data = doc.data();
        if (data['date'] is Timestamp) {
          final d = (data['date'] as Timestamp).toDate();
          return d.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              d.isBefore(endOfDay.add(const Duration(seconds: 1)));
        }
        return false;
      });

      return matches
          .map((doc) => PlannedScheduleModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveSchedule(PlannedScheduleEntity schedule) async {
    final startOfDay = DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
    final docId = schedule.id.isNotEmpty
        ? schedule.id
        : 'sched_${schedule.employeeId}_${startOfDay.millisecondsSinceEpoch}';

    final model = PlannedScheduleModel(
      id: docId,
      employeeId: schedule.employeeId,
      employeeName: schedule.employeeName,
      companyId: schedule.companyId,
      departmentId: schedule.departmentId,
      date: startOfDay,
      activities: schedule.activities,
      isPublished: schedule.isPublished,
    );

    // Save under document ID
    await _firestore
        .collection(AppConstants.collectionSchedules)
        .doc(docId)
        .set(model.toFirestore());

    // Also write canonical copy for exact employeeId & date matching
    final canonicalId = 'sched_${schedule.employeeId}_${startOfDay.millisecondsSinceEpoch}';
    if (docId != canonicalId) {
      await _firestore
          .collection(AppConstants.collectionSchedules)
          .doc(canonicalId)
          .set(model.toFirestore());
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    await _firestore
        .collection(AppConstants.collectionSchedules)
        .doc(scheduleId)
        .delete();
  }

  @override
  Future<void> recordActivityTransition(ActualActivityTransitionEntity transition) async {
    final model = ActualActivityTransitionModel(
      id: transition.id,
      employeeId: transition.employeeId,
      companyId: transition.companyId,
      plannedActivityId: transition.plannedActivityId,
      plannedActivityName: transition.plannedActivityName,
      actualActivityName: transition.actualActivityName,
      timestamp: transition.timestamp,
      adherenceStatus: transition.adherenceStatus,
      deviationMinutes: transition.deviationMinutes,
    );

    await _firestore
        .collection(AppConstants.collectionActivityTransitions)
        .doc(transition.id)
        .set(model.toFirestore());
  }

  @override
  Future<List<ActualActivityTransitionEntity>> getTransitionsForEmployee(
      String employeeId, DateTime date) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionActivityTransitions)
          .where('employeeId', isEqualTo: employeeId)
          .get();

      return snapshot.docs
          .map((doc) => ActualActivityTransitionModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  PlannedScheduleEntity _createInitialSchedule(String employeeId, String employeeName, DateTime day) {
    final year = day.year;
    final month = day.month;
    final d = day.day;
    final startOfDay = DateTime(year, month, d);

    final activities = [
      PlannedActivityEntity(
        id: 'act_1',
        name: 'Morning Work Session',
        code: 'WORK',
        colorHex: '#3B82F6',
        iconName: 'work',
        startTime: DateTime(year, month, d, 9, 0),
        endTime: DateTime(year, month, d, 11, 0),
        durationMinutes: 120,
      ),
      PlannedActivityEntity(
        id: 'act_2',
        name: 'Morning Break',
        code: 'BREAK',
        colorHex: '#14B8A6',
        iconName: 'coffee',
        startTime: DateTime(year, month, d, 11, 0),
        endTime: DateTime(year, month, d, 11, 15),
        durationMinutes: 15,
      ),
      PlannedActivityEntity(
        id: 'act_3',
        name: 'Core Tasks & Support',
        code: 'WORK',
        colorHex: '#3B82F6',
        iconName: 'laptop',
        startTime: DateTime(year, month, d, 11, 15),
        endTime: DateTime(year, month, d, 13, 0),
        durationMinutes: 105,
      ),
      PlannedActivityEntity(
        id: 'act_4',
        name: 'Lunch Break',
        code: 'LUNCH',
        colorHex: '#F59E0B',
        iconName: 'restaurant',
        startTime: DateTime(year, month, d, 13, 0),
        endTime: DateTime(year, month, d, 14, 0),
        durationMinutes: 60,
      ),
      PlannedActivityEntity(
        id: 'act_5',
        name: 'Team Sync & Projects',
        code: 'MEETING',
        colorHex: '#EC4899',
        iconName: 'groups',
        startTime: DateTime(year, month, d, 14, 0),
        endTime: DateTime(year, month, d, 16, 0),
        durationMinutes: 120,
      ),
      PlannedActivityEntity(
        id: 'act_6',
        name: 'Afternoon Break',
        code: 'BREAK',
        colorHex: '#14B8A6',
        iconName: 'local_cafe',
        startTime: DateTime(year, month, d, 16, 0),
        endTime: DateTime(year, month, d, 16, 15),
        durationMinutes: 15,
      ),
      PlannedActivityEntity(
        id: 'act_7',
        name: 'Wrap-Up & Handover',
        code: 'WORK',
        colorHex: '#3B82F6',
        iconName: 'assignment_turn_in',
        startTime: DateTime(year, month, d, 16, 15),
        endTime: DateTime(year, month, d, 17, 0),
        durationMinutes: 45,
      ),
    ];

    return PlannedScheduleEntity(
      id: 'sched_${employeeId}_${startOfDay.millisecondsSinceEpoch}',
      employeeId: employeeId,
      employeeName: employeeName.isNotEmpty ? employeeName : 'Employee',
      companyId: 'company_001',
      departmentId: 'dept_001',
      date: startOfDay,
      activities: activities,
      isPublished: true,
    );
  }
}
