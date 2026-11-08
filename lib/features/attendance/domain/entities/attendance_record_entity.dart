import 'package:equatable/equatable.dart';

class AttendanceRecordEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String companyId;
  final DateTime date;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final String status; // 'On-Time', 'Late', 'Missed', 'Clocked-In'
  final String? note;

  const AttendanceRecordEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.companyId,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    required this.status,
    this.note,
  });

  bool get isClockedIn => clockInTime != null && clockOutTime == null;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        companyId,
        date,
        clockInTime,
        clockOutTime,
        status,
        note,
      ];
}
