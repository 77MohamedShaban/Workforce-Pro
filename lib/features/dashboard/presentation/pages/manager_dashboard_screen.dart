import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes_manager/routes_name.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../reports/presentation/cubit/report_cubit.dart';
import '../../../reports/presentation/cubit/report_state.dart';

class ManagerDashboardScreen extends StatefulWidget {
  final UserEntity user;

  const ManagerDashboardScreen({super.key, required this.user});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final companyId = widget.user.companyId ?? 'company_001';
    context.read<ReportCubit>().loadReportSummary(companyId);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Summary Card
          BlocBuilder<ReportCubit, ReportState>(
            builder: (context, state) {
              final data = state is ReportLoaded
                  ? state.summary
                  : {
                      'totalEmployees': 12,
                      'clockedInCount': 10,
                      'attendanceRate': '83.3%',
                      'adherenceRate': '92.5%',
                      'pendingRequests': 2,
                    };

              return Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'dashboard'.tr(),
                          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'MANAGER',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${widget.user.companyName ?? 'Workforce Pro'} • Realtime Overview',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                    SizedBox(height: 20.h),

                    // Metrics Row
                    Row(
                      children: [
                        _buildMetricCol('Clocked In', '${data['clockedInCount']}/${data['totalEmployees']}', AppColors.success),
                        _buildMetricCol('Pending Reqs', '${data['pendingRequests']}', AppColors.warning),
                        _buildMetricCol('Adherence', '${data['adherenceRate']}', AppColors.blue),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 24.h),

          // Quick Tools Grid
          Text('Manager Tools', style: AppTextStyles.headingSmall),
          SizedBox(height: 12.h),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.3,
            children: [
              _buildToolCard(
                context,
                title: 'Conversations',
                icon: Icons.chat_bubble_outline,
                color: const Color(0xFF0284C7),
                routeName: RoutesName.conversations,
              ),
              _buildToolCard(
                context,
                title: 'employees'.tr(),
                icon: Icons.people_outline,
                color: AppColors.blue,
                routeName: RoutesName.employeeManagement,
              ),
              _buildToolCard(
                context,
                title: 'departments'.tr(),
                icon: Icons.business_outlined,
                color: AppColors.teal,
                routeName: RoutesName.departmentManagement,
              ),
              _buildToolCard(
                context,
                title: 'activity_library'.tr(),
                icon: Icons.local_activity_outlined,
                color: AppColors.warning,
                routeName: RoutesName.activityLibrary,
              ),
              _buildToolCard(
                context,
                title: 'Schedule Builder',
                icon: Icons.calendar_month_outlined,
                color: const Color(0xFF8B5CF6),
                routeName: RoutesName.scheduleBuilder,
              ),
              _buildToolCard(
                context,
                title: 'reports'.tr(),
                icon: Icons.bar_chart_outlined,
                color: const Color(0xFFEC4899),
                routeName: RoutesName.reports,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String routeName,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32.sp, color: color),
              SizedBox(height: 8.h),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
