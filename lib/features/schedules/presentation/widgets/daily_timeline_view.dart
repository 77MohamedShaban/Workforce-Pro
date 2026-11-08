import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/status_badge.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../domain/entities/actual_activity_transition_entity.dart';
import '../../domain/entities/planned_activity_entity.dart';
import '../../domain/entities/planned_schedule_entity.dart';

class DailyTimelineView extends StatefulWidget {
  final PlannedScheduleEntity schedule;
  final List<ActualActivityTransitionEntity> transitions;
  final bool isClockedIn;
  final Function(String actualName, PlannedActivityEntity? plannedAct) onActivityChanged;

  const DailyTimelineView({
    super.key,
    required this.schedule,
    required this.transitions,
    this.isClockedIn = true,
    required this.onActivityChanged,
  });

  @override
  State<DailyTimelineView> createState() => _DailyTimelineViewState();
}

class _DailyTimelineViewState extends State<DailyTimelineView> {
  late Timer _tickerTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Live ticker to move the red line dynamically with time
    _tickerTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer.cancel();
    super.dispose();
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

  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'coffee':
      case 'local_cafe':
        return Icons.local_cafe_outlined;
      case 'restaurant':
      case 'lunch':
        return Icons.restaurant_outlined;
      case 'groups':
      case 'meeting':
        return Icons.groups_outlined;
      case 'laptop':
      case 'work':
      default:
        return Icons.work_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentActivity = widget.schedule.getCurrentActivity(_now, isClockedIn: widget.isClockedIn);
    final nextActivity = widget.schedule.getNextActivity(_now, isClockedIn: widget.isClockedIn);
    final progress = widget.schedule.getShiftProgress(_now, isClockedIn: widget.isClockedIn);
    final latestTransition = widget.transitions.isNotEmpty ? widget.transitions.last : null;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clock-In Warning Notice Banner (If Employee is not clocked in yet)
          if (!widget.isClockedIn) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Clock-In Required: Shift tracking is paused until you Clock In from Attendance.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Header Card: Shift Status & Progress
          _buildShiftHeaderCard(context, currentActivity, nextActivity, latestTransition, progress),
          SizedBox(height: 24.h),

          // Timeline Section Title & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'schedule'.tr(),
                style: AppTextStyles.headingSmall,
              ),
              Text(
                DateFormat('EEEE, MMM d').format(widget.schedule.date),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Vertical Chronological Timeline
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.schedule.activities.length,
            itemBuilder: (context, index) {
              final act = widget.schedule.activities[index];
              final isCurrent = widget.isClockedIn && act.isCurrent(_now);
              final isPast = widget.isClockedIn && act.isPast(_now);
              final isUpcoming = !isPast && !isCurrent;

              final showYouAreHereBefore = widget.isClockedIn && index == 0 && _now.isBefore(act.startTime);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showYouAreHereBefore) ...[
                    _buildRedTimeMarkerLine(_now),
                    SizedBox(height: 12.h),
                  ],
                  _buildTimelineItem(context, act, index, widget.schedule.activities.length, isCurrent, isPast, isUpcoming),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShiftHeaderCard(
    BuildContext context,
    PlannedActivityEntity? current,
    PlannedActivityEntity? next,
    ActualActivityTransitionEntity? latestTransition,
    double progress,
  ) {
    final remainingMinutes = current != null ? current.endTime.difference(_now).inMinutes : 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: widget.isClockedIn ? AppColors.teal : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.isClockedIn ? 'current_activity'.tr() : 'SHIFT STATUS',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              if (current != null && widget.isClockedIn)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${'remaining_time'.tr()}: ${remainingMinutes > 0 ? remainingMinutes : 0} m',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            widget.isClockedIn
                ? (current?.name ?? 'Off-Shift / Unscheduled')
                : 'Waiting for Attendance Clock-In',
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          if (latestTransition != null && widget.isClockedIn) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Text(
                  'Actual: ${latestTransition.actualActivityName}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8.w),
                StatusBadge(status: latestTransition.adherenceStatus),
              ],
            ),
          ],
          if (next != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  '${'next_activity'.tr()}: ',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                Text(
                  '${next.name} (${DateFormat('hh:mm a').format(next.startTime)})',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          // Shift Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'shift_progress'.tr(),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
            ),
          ),
          SizedBox(height: 16.h),
          // Change Activity Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppColors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () => _showChangeActivityDialog(context, current),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Change Actual Activity'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRedTimeMarkerLine(DateTime time) {
    final timeStr = DateFormat('hh:mm a').format(time);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.my_location, size: 12, color: Colors.white),
              SizedBox(width: 4.w),
              Text(
                '📍 $timeStr',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            height: 2.5.h,
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    PlannedActivityEntity act,
    int index,
    int totalCount,
    bool isCurrent,
    bool isPast,
    bool isUpcoming,
  ) {
    final color = _parseColor(act.colorHex);
    final icon = _parseIcon(act.iconName);
    final isLast = index == totalCount - 1;

    // Proportional progress fraction within the current active activity (0.0 to 1.0)
    double currentActFraction = 0.0;
    if (isCurrent && widget.isClockedIn) {
      final totalSec = act.endTime.difference(act.startTime).inSeconds;
      final elapsedSec = _now.difference(act.startTime).inSeconds;
      if (totalSec > 0) {
        currentActFraction = (elapsedSec / totalSec).clamp(0.0, 1.0);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Column
        SizedBox(
          width: 65.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('hh:mm a').format(act.startTime),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? AppColors.blue : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${act.durationMinutes}m',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),

        // Vertical Line & Node
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isCurrent ? color : (isPast ? color.withValues(alpha: 0.3) : Colors.transparent),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? AppColors.error : color,
                  width: isCurrent ? 3 : 2,
                ),
              ),
              child: Icon(
                isPast ? Icons.check : icon,
                size: 14.sp,
                color: isCurrent ? Colors.white : color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: isCurrent ? 90.h : 70.h,
                color: isPast ? color.withValues(alpha: 0.3) : AppColors.border,
              ),
          ],
        ),
        SizedBox(width: 12.w),

        // Activity Card
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isCurrent ? AppColors.error : AppColors.border,
                width: isCurrent ? 2 : 1,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              act.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ),
                          StatusBadge(
                            status: isCurrent
                                ? 'Current'
                                : (isPast ? 'Completed' : 'Upcoming'),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14.sp, color: AppColors.textMuted),
                          SizedBox(width: 4.w),
                          Text(
                            '${DateFormat('hh:mm a').format(act.startTime)} - ${DateFormat('hh:mm a').format(act.endTime)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Moving Red Time Marker inside the current activity card!
                if (isCurrent && widget.isClockedIn) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRedTimeMarkerLine(_now),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress in activity:',
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp, color: AppColors.error),
                            ),
                            Text(
                              '${(currentActFraction * 100).toInt()}%',
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp, color: AppColors.error, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showChangeActivityDialog(BuildContext context, PlannedActivityEntity? current) {
    final activities = ['Work', 'Break', 'Lunch', 'Meeting', 'Training', 'Wrap-Up'];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Actual Activity', style: AppTextStyles.headingSmall),
              SizedBox(height: 8.h),
              Text(
                'Select your new activity transition. Your actual activity and adherence will be recorded in Firestore.',
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: activities.map((act) {
                  return ActionChip(
                    avatar: const Icon(Icons.circle, size: 10, color: AppColors.blue),
                    label: Text(act),
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onActivityChanged(act, current);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
