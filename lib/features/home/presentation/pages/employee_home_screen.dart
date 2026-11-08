import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/status_badge.dart';
import '../../../../core/routes_manager/routes_name.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../attendance/presentation/cubit/attendance_cubit.dart';
import '../../../attendance/presentation/cubit/attendance_state.dart';
import '../../../schedules/presentation/cubit/schedule_cubit.dart';
import '../../../schedules/presentation/cubit/schedule_state.dart';

class EmployeeHomeScreen extends StatelessWidget {
  final UserEntity user;
  final Function(int) onNavigateToTab;

  const EmployeeHomeScreen({
    super.key,
    required this.user,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & User Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'welcome'.tr()}, ${user.fullName}!',
                      style: AppTextStyles.headingSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${user.departmentName ?? 'Department'} • ${user.role.toUpperCase()}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.navy,
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                  style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Clock In / Clock Out Status Banner
          BlocBuilder<AttendanceCubit, AttendanceState>(
            builder: (context, state) {
              final todayRec = state is AttendanceLoaded ? state.todayRecord : null;
              final isClockedIn = todayRec?.isClockedIn ?? false;
              final String statusSubtitle = (isClockedIn && todayRec?.clockInTime != null)
                  ? 'Since ${DateFormat('hh:mm a').format(todayRec!.clockInTime!)}'
                  : 'Tap Attendance to Clock In for your shift';

              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isClockedIn
                        ? [AppColors.success, const Color(0xFF15803D)]
                        : [AppColors.blue, AppColors.navy],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isClockedIn ? Icons.timer_outlined : Icons.touch_app_outlined,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isClockedIn ? 'clocked_in'.tr() : 'clocked_out'.tr(),
                            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            statusSubtitle,
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: isClockedIn ? AppColors.success : AppColors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      ),
                      onPressed: () => onNavigateToTab(3), // Navigate to Attendance Tab
                      child: Text(isClockedIn ? 'clock_out'.tr() : 'clock_in'.tr()),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 24.h),

          // Today's Schedule Quick Overview Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('schedule'.tr(), style: AppTextStyles.headingSmall),
              TextButton(
                onPressed: () => onNavigateToTab(1), // Navigate to Schedule Timeline
                child: const Text('View Timeline'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, state) {
              if (state is ScheduleLoaded) {
                final current = state.schedule.getCurrentActivity(DateTime.now());
                final next = state.schedule.getNextActivity(DateTime.now());

                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule, color: AppColors.blue, size: 24.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('current_activity'.tr(), style: AppTextStyles.bodySmall),
                                  Text(
                                    current?.name ?? 'Off-Shift',
                                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            if (current != null)
                              StatusBadge(status: 'In-Progress'),
                          ],
                        ),
                        if (next != null) ...[
                          const Divider(height: 24),
                          Row(
                            children: [
                              Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 16.sp),
                              SizedBox(width: 12.w),
                              Text('next_activity'.tr(), style: AppTextStyles.bodySmall),
                              SizedBox(width: 8.w),
                              Text(
                                '${next.name} (${DateFormat('hh:mm a').format(next.startTime)})',
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Loading schedule...'),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),

          // Quick Actions Row
          Text('Quick Actions', style: AppTextStyles.headingSmall),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Messages',
                  color: const Color(0xFF0284C7),
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.conversations);
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildActionTile(
                  context,
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'requests'.tr(),
                  color: AppColors.teal,
                  onTap: () => onNavigateToTab(2),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildActionTile(
                  context,
                  icon: Icons.fingerprint,
                  title: 'attendance'.tr(),
                  color: AppColors.blue,
                  onTap: () => onNavigateToTab(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28.sp, color: color),
            SizedBox(height: 6.h),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
