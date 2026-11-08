import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/planned_activity_entity.dart';

class PlannedActivityModel extends PlannedActivityEntity {
  const PlannedActivityModel({
    required super.id,
    required super.name,
    required super.code,
    required super.colorHex,
    required super.iconName,
    required super.startTime,
    required super.endTime,
    required super.durationMinutes,
  });

  factory PlannedActivityModel.fromFirestore(Map<String, dynamic> json) {
    return PlannedActivityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      colorHex: json['colorHex'] ?? '#3B82F6',
      iconName: json['iconName'] ?? 'work',
      startTime: json['startTime'] is Timestamp
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.parse(json['startTime']),
      endTime: json['endTime'] is Timestamp
          ? (json['endTime'] as Timestamp).toDate()
          : DateTime.parse(json['endTime']),
      durationMinutes: json['durationMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'colorHex': colorHex,
      'iconName': iconName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMinutes': durationMinutes,
    };
  }
}
