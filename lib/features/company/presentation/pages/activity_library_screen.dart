import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/empty_state_widget.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/activity_definition_entity.dart';
import '../cubit/company_cubit.dart';
import '../cubit/company_state.dart';

class ActivityLibraryScreen extends StatefulWidget {
  const ActivityLibraryScreen({super.key});

  @override
  State<ActivityLibraryScreen> createState() => _ActivityLibraryScreenState();
}

class _ActivityLibraryScreenState extends State<ActivityLibraryScreen> {
  @override
  void initState() {
    super.initState();
    final companyId = context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
    context.read<CompanyCubit>().loadCompanyData(companyId);
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('activity_library'.tr()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivityDialog,
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const LoadingIndicator();
          }

          if (state is CompanyLoaded) {
            if (state.activities.isEmpty) {
              return const EmptyStateWidget(
                message: 'No activities defined.',
                icon: Icons.local_activity_outlined,
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.activities.length,
              itemBuilder: (context, index) {
                final act = state.activities[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: ListTile(
                    leading: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: _parseColor(act.colorHex),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(act.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('Code: ${act.code} • ${act.isPaidBreak ? 'Paid' : 'Unpaid'}'),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddActivityDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Activity Definition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Activity Name')),
            const SizedBox(height: 12),
            TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Code (e.g. WORK)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final companyId = context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
                final act = ActivityDefinitionEntity(
                  id: 'act_def_${DateTime.now().millisecondsSinceEpoch}',
                  companyId: companyId,
                  name: nameController.text.trim(),
                  code: codeController.text.trim().toUpperCase(),
                  colorHex: '#3B82F6',
                  iconName: 'work',
                  isPaidBreak: true,
                );
                context.read<CompanyCubit>().addActivityDefinition(act);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
