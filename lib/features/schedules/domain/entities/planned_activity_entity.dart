import 'package:equatable/equatable.dart';

class PlannedActivityEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String colorHex;
  final String iconName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;

  const PlannedActivityEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.colorHex,
    required this.iconName,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });

  bool isCurrent(DateTime now) {
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool isPast(DateTime now) {
    return now.isAfter(endTime);
  }

  bool isUpcoming(DateTime now) {
    return now.isBefore(startTime);
  }

  @override
  List<Object?> get props => [id, name, code, colorHex, iconName, startTime, endTime, durationMinutes];
}
