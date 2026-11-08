import 'package:equatable/equatable.dart';

class RequestEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String companyId;
  final String type; // 'Two-Hour Late', 'PTO', 'Early Leave', 'Overtime', 'VGH'
  final String reason;
  final DateTime date;
  final String status; // 'Pending', 'Approved', 'Rejected', 'Cancelled'
  final String? managerNotes;
  final DateTime createdAt;

  const RequestEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.companyId,
    required this.type,
    required this.reason,
    required this.date,
    required this.status,
    this.managerNotes,
    required this.createdAt,
  });

  bool get isPending => status == 'Pending';

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        companyId,
        type,
        reason,
        date,
        status,
        managerNotes,
        createdAt,
      ];
}
