import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/request_entity.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.companyId,
    required super.type,
    required super.reason,
    required super.date,
    required super.status,
    super.managerNotes,
    required super.createdAt,
  });

  factory RequestModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return RequestModel(
      id: docId,
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      companyId: json['companyId'] ?? '',
      type: json['type'] ?? 'PTO',
      reason: json['reason'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      status: json['status'] ?? 'Pending',
      managerNotes: json['managerNotes'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'companyId': companyId,
      'type': type,
      'reason': reason,
      'date': Timestamp.fromDate(date),
      'status': status,
      'managerNotes': managerNotes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
