import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/attendance_record_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_record_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final FirebaseFirestore _firestore;

  AttendanceRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AttendanceRecordEntity?> getTodayAttendance(String employeeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final canonicalDocId = 'att_${employeeId}_${startOfDay.millisecondsSinceEpoch}';

    try {
      // 1. Direct canonical document lookup
      final directDoc = await _firestore
          .collection(AppConstants.collectionAttendance)
          .doc(canonicalDocId)
          .get();

      if (directDoc.exists && directDoc.data() != null) {
        return AttendanceRecordModel.fromFirestore(
          directDoc.data()!,
          directDoc.id,
        );
      }

      // 2. Query all attendance records matching employeeId and today's date
      final snapshot = await _firestore
          .collection(AppConstants.collectionAttendance)
          .get();

      final matches = snapshot.docs.where((doc) {
        final data = doc.data();
        final matchEmp = data['employeeId'] == employeeId;
        bool matchDate = false;
        if (data['date'] is Timestamp) {
          final d = (data['date'] as Timestamp).toDate();
          matchDate = d.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              d.isBefore(endOfDay.add(const Duration(seconds: 1)));
        }
        return matchEmp && matchDate;
      }).toList();

      if (matches.isNotEmpty) {
        return AttendanceRecordModel.fromFirestore(
          matches.last.data(),
          matches.last.id,
        );
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<AttendanceRecordEntity> clockIn(
      String employeeId, String employeeName, String companyId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final recordId = 'att_${employeeId}_${startOfDay.millisecondsSinceEpoch}';

    final model = AttendanceRecordModel(
      id: recordId,
      employeeId: employeeId,
      employeeName: employeeName,
      companyId: companyId,
      date: startOfDay,
      clockInTime: now,
      status: 'On-Time',
    );

    await _firestore
        .collection(AppConstants.collectionAttendance)
        .doc(recordId)
        .set(model.toFirestore());

    return model;
  }

  @override
  Future<AttendanceRecordEntity> clockOut(String employeeId, String recordId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final canonicalId = 'att_${employeeId}_${startOfDay.millisecondsSinceEpoch}';
    final todayRec = await getTodayAttendance(employeeId);

    final updatedModel = AttendanceRecordModel(
      id: recordId,
      employeeId: employeeId,
      employeeName: todayRec?.employeeName ?? 'Employee',
      companyId: todayRec?.companyId ?? 'company_001',
      date: todayRec?.date ?? startOfDay,
      clockInTime: todayRec?.clockInTime ?? now.subtract(const Duration(hours: 8)),
      clockOutTime: now,
      status: 'On-Time',
    );

    try {
      await _firestore
          .collection(AppConstants.collectionAttendance)
          .doc(recordId)
          .set(updatedModel.toFirestore(), SetOptions(merge: true));

      if (recordId != canonicalId) {
        await _firestore
            .collection(AppConstants.collectionAttendance)
            .doc(canonicalId)
            .set(updatedModel.toFirestore(), SetOptions(merge: true));
      }
    } catch (_) {}

    return updatedModel;
  }

  @override
  Future<List<AttendanceRecordEntity>> getAttendanceHistory(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionAttendance)
          .get();

      final list = snapshot.docs
          .where((doc) => doc.data()['employeeId'] == employeeId)
          .map((doc) => AttendanceRecordModel.fromFirestore(doc.data(), doc.id))
          .toList();

      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (_) {
      return [];
    }
  }
}
