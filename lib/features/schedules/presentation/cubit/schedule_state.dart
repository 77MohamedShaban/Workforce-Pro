import 'package:equatable/equatable.dart';
import '../../domain/entities/actual_activity_transition_entity.dart';
import '../../domain/entities/planned_schedule_entity.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final PlannedScheduleEntity schedule;
  final List<ActualActivityTransitionEntity> transitions;

  const ScheduleLoaded({
    required this.schedule,
    this.transitions = const [],
  });

  @override
  List<Object?> get props => [schedule, transitions];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
