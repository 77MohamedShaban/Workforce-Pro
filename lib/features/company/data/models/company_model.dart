import '../../domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.id,
    required super.name,
    super.workingHours = '09:00 - 17:00',
    super.timezone = 'UTC',
    super.adherenceToleranceMinutes = 2,
  });

  factory CompanyModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return CompanyModel(
      id: docId,
      name: json['name'] ?? '',
      workingHours: json['workingHours'] ?? '09:00 - 17:00',
      timezone: json['timezone'] ?? 'UTC',
      adherenceToleranceMinutes: json['adherenceToleranceMinutes'] ?? 2,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'workingHours': workingHours,
      'timezone': timezone,
      'adherenceToleranceMinutes': adherenceToleranceMinutes,
    };
  }
}
