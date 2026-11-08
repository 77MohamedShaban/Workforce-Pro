import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/planned_schedule_entity.dart';
import 'planned_activity_model.dart';

class PlannedScheduleModel extends PlannedScheduleEntity {
  const PlannedScheduleModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.companyId,
    required super.departmentId,
    required super.date,
    required super.activities,
    super.isPublished = true,
  });

  factory PlannedScheduleModel.fromFirestore(Map<String, dynamic> json, String docId) {
    final rawActs = json['activities'] as List<dynamic>? ?? [];
    final activities = rawActs.map((e) => PlannedActivityModel.fromFirestore(e)).toList();

    return PlannedScheduleModel(
      id: docId,
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      companyId: json['companyId'] ?? '',
      departmentId: json['departmentId'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      activities: activities,
      isPublished: json['isPublished'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'companyId': companyId,
      'departmentId': departmentId,
      'date': Timestamp.fromDate(date),
      'activities': activities.map((a) {
        if (a is PlannedActivityModel) return a.toFirestore();
        return PlannedActivityModel(
          id: a.id,
          name: a.name,
          code: a.code,
          colorHex: a.colorHex,
          iconName: a.iconName,
          startTime: a.startTime,
          endTime: a.endTime,
          durationMinutes: a.durationMinutes,
        ).toFirestore();
      }).toList(),
      'isPublished': isPublished,
    };
  }
}
