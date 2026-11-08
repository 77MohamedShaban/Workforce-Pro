import '../entities/actual_activity_transition_entity.dart';
import '../entities/planned_schedule_entity.dart';

abstract class ScheduleRepository {
  Future<PlannedScheduleEntity?> getScheduleForEmployee(String employeeId, DateTime date);
  Future<List<PlannedScheduleEntity>> getCompanySchedules(String companyId, DateTime date);
  Future<void> saveSchedule(PlannedScheduleEntity schedule);
  Future<void> deleteSchedule(String scheduleId);
  Future<void> recordActivityTransition(ActualActivityTransitionEntity transition);
  Future<List<ActualActivityTransitionEntity>> getTransitionsForEmployee(String employeeId, DateTime date);
}
