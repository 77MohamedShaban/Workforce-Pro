import 'package:equatable/equatable.dart';
import 'planned_activity_entity.dart';

class PlannedScheduleEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String companyId;
  final String departmentId;
  final DateTime date;
  final List<PlannedActivityEntity> activities;
  final bool isPublished;

  const PlannedScheduleEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.companyId,
    required this.departmentId,
    required this.date,
    required this.activities,
    this.isPublished = true,
  });

  PlannedActivityEntity? getCurrentActivity(DateTime now, {bool isClockedIn = true}) {
    if (!isClockedIn) return null;
    for (final act in activities) {
      if (act.isCurrent(now)) return act;
    }
    return null;
  }

  PlannedActivityEntity? getNextActivity(DateTime now, {bool isClockedIn = true}) {
    if (!isClockedIn) return activities.isNotEmpty ? activities.first : null;
    for (final act in activities) {
      if (act.isUpcoming(now)) return act;
    }
    return null;
  }

  double getShiftProgress(DateTime now, {bool isClockedIn = true}) {
    if (!isClockedIn || activities.isEmpty) return 0.0;

    final sorted = List<PlannedActivityEntity>.from(activities)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final shiftStart = sorted.first.startTime;
    final shiftEnd = sorted.last.endTime;

    if (now.isBefore(shiftStart)) return 0.0;
    if (now.isAfter(shiftEnd)) return 1.0;

    double completedMinutes = 0.0;
    double totalMinutes = 0.0;

    for (final act in sorted) {
      final actDuration = act.endTime.difference(act.startTime).inMinutes.toDouble();
      final validDuration = actDuration > 0 ? actDuration : 1.0;
      totalMinutes += validDuration;

      if (now.isAfter(act.endTime)) {
        completedMinutes += validDuration;
      } else if (now.isAfter(act.startTime) && now.isBefore(act.endTime)) {
        final elapsed = now.difference(act.startTime).inMinutes.toDouble();
        completedMinutes += elapsed.clamp(0.0, validDuration);
      }
    }

    if (totalMinutes <= 0) return 0.0;
    return (completedMinutes / totalMinutes).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        companyId,
        departmentId,
        date,
        activities,
        isPublished,
      ];
}
