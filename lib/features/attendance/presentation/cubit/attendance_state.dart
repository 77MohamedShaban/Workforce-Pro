import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_record_entity.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final AttendanceRecordEntity? todayRecord;
  final List<AttendanceRecordEntity> history;

  const AttendanceLoaded({
    this.todayRecord,
    this.history = const [],
  });

  @override
  List<Object?> get props => [todayRecord, history];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
