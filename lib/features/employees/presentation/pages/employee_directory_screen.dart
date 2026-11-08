import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/empty_state_widget.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/routes_manager/routes_name.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/employee_cubit.dart';
import '../cubit/employee_state.dart';

class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  State<EmployeeDirectoryScreen> createState() => _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  @override
  void initState() {
    super.initState();
    final companyId = context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
    context.read<EmployeeCubit>().loadEmployees(companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('employees'.tr()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const LoadingIndicator();
          }

          if (state is EmployeeLoaded) {
            if (state.employees.isEmpty) {
              return const EmptyStateWidget(
                message: 'No employees found in directory.',
                icon: Icons.people_outline,
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.employees.length,
              itemBuilder: (context, index) {
                final emp = state.employees[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutesName.employeeDetails,
                        arguments: emp,
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: AppColors.navy,
                      child: Text(
                        emp.fullName.isNotEmpty ? emp.fullName[0].toUpperCase() : 'E',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(emp.fullName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('${emp.departmentName ?? 'Department'} • ${emp.email}'),
                    trailing: const Icon(Icons.chevron_right),
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

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = AppConstants.roleEmployee;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty && emailController.text.trim().isNotEmpty) {
                final companyId = context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
                final newEmp = UserEntity(
                  id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
                  email: emailController.text.trim(),
                  fullName: nameController.text.trim(),
                  role: selectedRole,
                  companyId: companyId,
                  companyName: 'Workforce Pro Ltd.',
                  departmentName: 'Engineering',
                );
                context.read<EmployeeCubit>().addEmployee(newEmp);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }
}
