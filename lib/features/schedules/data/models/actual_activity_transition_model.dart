import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/actual_activity_transition_entity.dart';

class ActualActivityTransitionModel extends ActualActivityTransitionEntity {
  const ActualActivityTransitionModel({
    required super.id,
    required super.employeeId,
    required super.companyId,
    super.plannedActivityId,
    required super.plannedActivityName,
    required super.actualActivityName,
    required super.timestamp,
    required super.adherenceStatus,
    super.deviationMinutes = 0,
  });

  factory ActualActivityTransitionModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return ActualActivityTransitionModel(
      id: docId,
      employeeId: json['employeeId'] ?? '',
      companyId: json['companyId'] ?? '',
      plannedActivityId: json['plannedActivityId'],
      plannedActivityName: json['plannedActivityName'] ?? '',
      actualActivityName: json['actualActivityName'] ?? '',
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      adherenceStatus: json['adherenceStatus'] ?? 'On-Time',
      deviationMinutes: json['deviationMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'companyId': companyId,
      'plannedActivityId': plannedActivityId,
      'plannedActivityName': plannedActivityName,
      'actualActivityName': actualActivityName,
      'timestamp': Timestamp.fromDate(timestamp),
      'adherenceStatus': adherenceStatus,
      'deviationMinutes': deviationMinutes,
    };
  }
}
