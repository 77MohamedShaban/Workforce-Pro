import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final String id;
  final String name;
  final String workingHours;
  final String timezone;
  final int adherenceToleranceMinutes;

  const CompanyEntity({
    required this.id,
    required this.name,
    this.workingHours = '09:00 - 17:00',
    this.timezone = 'UTC',
    this.adherenceToleranceMinutes = 2,
  });

  @override
  List<Object?> get props => [id, name, workingHours, timezone, adherenceToleranceMinutes];
}
