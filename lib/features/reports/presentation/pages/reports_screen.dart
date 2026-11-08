import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedDepartment = 'All Departments';

  @override
  void initState() {
    super.initState();
    final companyId = context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
    context.read<ReportCubit>().loadReportSummary(companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reports'.tr()),
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const LoadingIndicator();
          }

          final data = state is ReportLoaded
              ? state.summary
              : {
                  'totalEmployees': 12,
                  'clockedInCount': 10,
                  'attendanceRate': '83.3%',
                  'adherenceRate': '92.5%',
                  'pendingRequests': 2,
                };

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Header
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  items: const [
                    DropdownMenuItem(value: 'All Departments', child: Text('All Departments')),
                    DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
                    DropdownMenuItem(value: 'Operations', child: Text('Operations')),
                    DropdownMenuItem(value: 'Customer Support', child: Text('Customer Support')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDepartment = val);
                  },
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Department'),
                ),
                SizedBox(height: 20.h),

                // Live Performance Overview Cards
                Row(
                  children: [
                    Expanded(child: _buildReportCard('Attendance Rate', data['attendanceRate'], AppColors.success, Icons.check_circle_outline)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildReportCard('Adherence Rate', data['adherenceRate'], AppColors.blue, Icons.speed_outlined)),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: _buildReportCard('Total Employees', '${data['totalEmployees']}', AppColors.teal, Icons.people_outline)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildReportCard('Pending Reqs', '${data['pendingRequests']}', AppColors.warning, Icons.assignment_turned_in)),
                  ],
                ),
                SizedBox(height: 24.h),

                // Activity Distribution Breakdown
                Text('Request Type Breakdown', style: AppTextStyles.headingSmall),
                SizedBox(height: 12.h),

                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        _buildBreakdownRow('PTO (Paid Time Off)', '45%', AppColors.blue),
                        const Divider(),
                        _buildBreakdownRow('Two-Hour Late', '25%', AppColors.warning),
                        const Divider(),
                        _buildBreakdownRow('Early Leave', '15%', AppColors.teal),
                        const Divider(),
                        _buildBreakdownRow('Overtime', '10%', const Color(0xFF8B5CF6)),
                        const Divider(),
                        _buildBreakdownRow('VGH (Voluntarily Gone Home)', '5%', const Color(0xFFEC4899)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.headingMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String pct, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              SizedBox(width: 8.w),
              Text(label, style: AppTextStyles.bodyMedium),
            ],
          ),
          Text(pct, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
