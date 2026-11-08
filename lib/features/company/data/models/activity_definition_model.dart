import '../../domain/entities/activity_definition_entity.dart';

class ActivityDefinitionModel extends ActivityDefinitionEntity {
  const ActivityDefinitionModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.code,
    required super.colorHex,
    required super.iconName,
    super.isPaidBreak = false,
  });

  factory ActivityDefinitionModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return ActivityDefinitionModel(
      id: docId,
      companyId: json['companyId'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      colorHex: json['colorHex'] ?? '#3B82F6',
      iconName: json['iconName'] ?? 'work',
      isPaidBreak: json['isPaidBreak'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyId': companyId,
      'name': name,
      'code': code,
      'colorHex': colorHex,
      'iconName': iconName,
      'isPaidBreak': isPaidBreak,
    };
  }
}
