import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attendance_record_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceCubit(this._repository) : super(AttendanceInitial());

  Future<void> loadAttendance(String employeeId) async {
    emit(AttendanceLoading());
    try {
      final today = await _repository.getTodayAttendance(employeeId);
      final history = await _repository.getAttendanceHistory(employeeId);
      emit(AttendanceLoaded(todayRecord: today, history: history));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> clockIn(String employeeId, String employeeName, String companyId) async {
    final currentState = state;
    emit(AttendanceLoading());
    try {
      final rec = await _repository.clockIn(employeeId, employeeName, companyId);
      final history = currentState is AttendanceLoaded ? currentState.history : <AttendanceRecordEntity>[];
      emit(AttendanceLoaded(todayRecord: rec, history: history));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> clockOut(String employeeId, String recordId) async {
    final currentState = state;
    emit(AttendanceLoading());
    try {
      final rec = await _repository.clockOut(employeeId, recordId);
      final history = currentState is AttendanceLoaded ? currentState.history : <AttendanceRecordEntity>[];
      emit(AttendanceLoaded(todayRecord: rec, history: history));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
