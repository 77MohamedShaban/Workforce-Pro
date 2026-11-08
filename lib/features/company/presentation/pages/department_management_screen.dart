import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/empty_state_widget.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/company_cubit.dart';
import '../cubit/company_state.dart';

class DepartmentManagementScreen extends StatefulWidget {
  const DepartmentManagementScreen({super.key});

  @override
  State<DepartmentManagementScreen> createState() => _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState extends State<DepartmentManagementScreen> {
  @override
  void initState() {
    super.initState();
    final companyId = context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
    context.read<CompanyCubit>().loadCompanyData(companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('departments'.tr()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDepartmentDialog,
        backgroundColor: AppColors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const LoadingIndicator();
          }

          if (state is CompanyLoaded) {
            if (state.departments.isEmpty) {
              return const EmptyStateWidget(
                message: 'No departments defined.',
                icon: Icons.business_outlined,
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.departments.length,
              itemBuilder: (context, index) {
                final dept = state.departments[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: ListTile(
                    leading: const Icon(Icons.business_outlined, color: AppColors.teal),
                    title: Text(dept.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('${dept.employeeCount} Employees'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

  void _showAddDepartmentDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Department'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Department Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final companyId = context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
                context.read<CompanyCubit>().addDepartment(companyId, nameController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }
}
