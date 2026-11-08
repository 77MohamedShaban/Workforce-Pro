import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/error_state_widget.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/reusable_component/status_badge.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';

class AttendanceScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String companyId;

  const AttendanceScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('attendance'.tr()),
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AttendanceLoaded && state.todayRecord != null) {
            final isClocked = state.todayRecord!.isClockedIn;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isClocked ? 'Clocked in successfully!' : 'Clocked out successfully!'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const LoadingIndicator();
          }

          if (state is AttendanceError) {
            return ErrorStateWidget(
              errorMessage: state.message,
              onRetry: () {
                context.read<AttendanceCubit>().loadAttendance(userId);
              },
            );
          }

          final today = state is AttendanceLoaded ? state.todayRecord : null;
          final history = state is AttendanceLoaded ? state.history : [];
          final isClockedIn = today?.isClockedIn ?? false;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Clock In / Clock Out Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        DateFormat('hh:mm:ss a').format(DateTime.now()),
                        style: AppTextStyles.headingLarge.copyWith(fontSize: 28.sp),
                      ),
                      SizedBox(height: 24.h),

                      // Action Button
                      GestureDetector(
                        onTap: () {
                          if (isClockedIn && today != null) {
                            context.read<AttendanceCubit>().clockOut(userId, today.id);
                          } else {
                            context.read<AttendanceCubit>().clockIn(userId, userName, companyId);
                          }
                        },
                        child: Container(
                          width: 140.w,
                          height: 140.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isClockedIn
                                  ? [AppColors.error, const Color(0xFFB91C1C)]
                                  : [AppColors.blue, AppColors.navy],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isClockedIn ? AppColors.error : AppColors.blue).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isClockedIn ? Icons.output_outlined : Icons.touch_app_outlined,
                                size: 40.sp,
                                color: Colors.white,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                isClockedIn ? 'clock_out'.tr() : 'clock_in'.tr(),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Today's Summary Times
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text('Clock In', style: AppTextStyles.bodySmall),
                              SizedBox(height: 4.h),
                              Text(
                                today?.clockInTime != null
                                    ? DateFormat('hh:mm a').format(today!.clockInTime!)
                                    : '--:--',
                                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(width: 1.w, height: 30.h, color: AppColors.border),
                          Column(
                            children: [
                              Text('Clock Out', style: AppTextStyles.bodySmall),
                              SizedBox(height: 4.h),
                              Text(
                                today?.clockOutTime != null
                                    ? DateFormat('hh:mm a').format(today!.clockOutTime!)
                                    : '--:--',
                                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Attendance History Log
                Text('Attendance History', style: AppTextStyles.headingSmall),
                SizedBox(height: 12.h),
                if (history.isEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Center(
                      child: Text(
                        'no_data'.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ] else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          title: Text(
                            DateFormat('EEEE, MMM d').format(item.date),
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'In: ${item.clockInTime != null ? DateFormat('hh:mm a').format(item.clockInTime!) : '--'} | Out: ${item.clockOutTime != null ? DateFormat('hh:mm a').format(item.clockOutTime!) : '--'}',
                          ),
                          trailing: StatusBadge(status: item.status),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
