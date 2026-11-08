import 'package:equatable/equatable.dart';

class ActivityDefinitionEntity extends Equatable {
  final String id;
  final String companyId;
  final String name;
  final String code;
  final String colorHex;
  final String iconName;
  final bool isPaidBreak;

  const ActivityDefinitionEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.code,
    required this.colorHex,
    required this.iconName,
    this.isPaidBreak = false,
  });

  @override
  List<Object?> get props => [id, companyId, name, code, colorHex, iconName, isPaidBreak];
}
