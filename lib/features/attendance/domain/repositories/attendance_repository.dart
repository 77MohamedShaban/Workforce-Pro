import '../entities/attendance_record_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceRecordEntity?> getTodayAttendance(String employeeId);
  Future<AttendanceRecordEntity> clockIn(String employeeId, String employeeName, String companyId);
  Future<AttendanceRecordEntity> clockOut(String employeeId, String recordId);
  Future<List<AttendanceRecordEntity>> getAttendanceHistory(String employeeId);
}
