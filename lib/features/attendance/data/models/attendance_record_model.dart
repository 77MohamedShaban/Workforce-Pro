import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_record_entity.dart';

class AttendanceRecordModel extends AttendanceRecordEntity {
  const AttendanceRecordModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.companyId,
    required super.date,
    super.clockInTime,
    super.clockOutTime,
    required super.status,
    super.note,
  });

  factory AttendanceRecordModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return AttendanceRecordModel(
      id: docId,
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      companyId: json['companyId'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      clockInTime: json['clockInTime'] is Timestamp
          ? (json['clockInTime'] as Timestamp).toDate()
          : null,
      clockOutTime: json['clockOutTime'] is Timestamp
          ? (json['clockOutTime'] as Timestamp).toDate()
          : null,
      status: json['status'] ?? 'On-Time',
      note: json['note'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'companyId': companyId,
      'date': Timestamp.fromDate(date),
      'clockInTime': clockInTime != null ? Timestamp.fromDate(clockInTime!) : null,
      'clockOutTime': clockOutTime != null ? Timestamp.fromDate(clockOutTime!) : null,
      'status': status,
      'note': note,
    };
  }
}
