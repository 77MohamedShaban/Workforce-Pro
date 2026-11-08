import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/actual_activity_transition_entity.dart';
import '../../domain/entities/planned_activity_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleCubit(this._repository) : super(ScheduleInitial());

  Future<void> loadSchedule(String employeeId, DateTime date) async {
    emit(ScheduleLoading());
    try {
      final schedule = await _repository.getScheduleForEmployee(employeeId, date);
      final transitions = await _repository.getTransitionsForEmployee(employeeId, date);

      if (schedule != null) {
        emit(ScheduleLoaded(schedule: schedule, transitions: transitions));
      } else {
        emit(const ScheduleError("No schedule available for this date."));
      }
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> changeActualActivity({
    required String employeeId,
    required String companyId,
    required String actualActivityName,
    PlannedActivityEntity? plannedActivity,
  }) async {
    final currentState = state;
    if (currentState is! ScheduleLoaded) return;

    final now = DateTime.now();
    String adherenceStatus = AppConstants.adherenceUnplanned;
    int deviationMinutes = 0;

    if (plannedActivity != null) {
      final diff = now.difference(plannedActivity.startTime).inMinutes;
      deviationMinutes = diff.abs();

      if (diff.abs() <= AppConstants.defaultAdherenceToleranceMinutes) {
        adherenceStatus = AppConstants.adherenceOnTime;
      } else if (diff > AppConstants.defaultAdherenceToleranceMinutes) {
        adherenceStatus = AppConstants.adherenceLate;
      } else {
        adherenceStatus = AppConstants.adherenceEarly;
      }
    }

    final transition = ActualActivityTransitionEntity(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      companyId: companyId,
      plannedActivityId: plannedActivity?.id,
      plannedActivityName: plannedActivity?.name ?? 'Unscheduled',
      actualActivityName: actualActivityName,
      timestamp: now,
      adherenceStatus: adherenceStatus,
      deviationMinutes: deviationMinutes,
    );

    await _repository.recordActivityTransition(transition);

    final updatedTransitions = List<ActualActivityTransitionEntity>.from(currentState.transitions)
      ..add(transition);

    emit(ScheduleLoaded(
      schedule: currentState.schedule,
      transitions: updatedTransitions,
    ));
  }
}
