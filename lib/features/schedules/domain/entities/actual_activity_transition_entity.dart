import 'package:equatable/equatable.dart';

class ActualActivityTransitionEntity extends Equatable {
  final String id;
  final String employeeId;
  final String companyId;
  final String? plannedActivityId;
  final String plannedActivityName;
  final String actualActivityName;
  final DateTime timestamp;
  final String adherenceStatus; // 'On-Time', 'Late', 'Early', 'Unplanned'
  final int deviationMinutes;

  const ActualActivityTransitionEntity({
    required this.id,
    required this.employeeId,
    required this.companyId,
    this.plannedActivityId,
    required this.plannedActivityName,
    required this.actualActivityName,
    required this.timestamp,
    required this.adherenceStatus,
    this.deviationMinutes = 0,
  });

  @override
  List<Object?> get props => [
        id,
        employeeId,
        companyId,
        plannedActivityId,
        plannedActivityName,
        actualActivityName,
        timestamp,
        adherenceStatus,
        deviationMinutes,
      ];
}
