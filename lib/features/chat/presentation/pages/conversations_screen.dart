import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/empty_state_widget.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/routes_manager/routes_name.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../employees/presentation/cubit/employee_cubit.dart';
import '../../../employees/presentation/cubit/employee_state.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final companyId = context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
    context.read<EmployeeCubit>().loadEmployees(companyId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations & Messages'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search employee to chat...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),

          // Employee Conversations List
          Expanded(
            child: BlocBuilder<EmployeeCubit, EmployeeState>(
              builder: (context, state) {
                if (state is EmployeeLoading) {
                  return const LoadingIndicator();
                }

                if (state is EmployeeLoaded) {
                  // Filter out current user from employee list
                  final otherEmployees = state.employees.where((emp) => emp.id != currentUser?.id).toList();

                  final filteredEmployees = otherEmployees.where((emp) {
                    return emp.fullName.toLowerCase().contains(_searchQuery) ||
                        (emp.departmentName?.toLowerCase().contains(_searchQuery) ?? false);
                  }).toList();

                  if (filteredEmployees.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'No employees found for messaging.',
                      icon: Icons.chat_bubble_outline,
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final emp = filteredEmployees[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: ListTile(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutesName.chat,
                              arguments: emp,
                            );
                          },
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 24.r,
                                backgroundColor: AppColors.navy,
                                child: Text(
                                  emp.fullName.isNotEmpty ? emp.fullName[0].toUpperCase() : 'E',
                                  style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              )
                            ],
                          ),
                          title: Text(emp.fullName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text('${emp.departmentName ?? 'Engineering'} • ${emp.role.toUpperCase()}'),
                          trailing: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline, color: AppColors.blue, size: 20),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          )
        ],
      ),
    );
  }
}
