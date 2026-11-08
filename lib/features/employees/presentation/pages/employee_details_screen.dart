import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/di.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/reusable_component/status_badge.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../attendance/domain/entities/attendance_record_entity.dart';
import '../../../attendance/domain/repositories/attendance_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../schedules/domain/entities/actual_activity_transition_entity.dart';
import '../../../schedules/domain/entities/planned_schedule_entity.dart';
import '../../../schedules/domain/repositories/schedule_repository.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final UserEntity employee;

  const EmployeeDetailsScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  bool _isLoading = true;
  DateTime _selectedShiftDate = DateTime.now();

  PlannedScheduleEntity? _schedule;
  List<ActualActivityTransitionEntity> _transitions = [];
  AttendanceRecordEntity? _todayAttendance;
  List<AttendanceRecordEntity> _attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData(_selectedShiftDate);
  }

  Future<void> _fetchEmployeeData(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      final sched = await getIt<ScheduleRepository>().getScheduleForEmployee(widget.employee.id, date);
      final trans = await getIt<ScheduleRepository>().getTransitionsForEmployee(widget.employee.id, date);
      final todayAtt = await getIt<AttendanceRepository>().getTodayAttendance(widget.employee.id);
      final historyAtt = await getIt<AttendanceRepository>().getAttendanceHistory(widget.employee.id);

      setState(() {
        _schedule = sched;
        _transitions = trans;
        _todayAttendance = todayAtt;
        _attendanceHistory = historyAtt;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
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

  Widget _buildSectionHeader(String title, DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.headingSmall),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, size: 13.sp, color: AppColors.blue),
              SizedBox(width: 6.w),
              Text(
                DateFormat('EEE, MMMM d, yyyy').format(date),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyEvaluationCard() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final monthlyAttList = _attendanceHistory.where((att) => att.date.isAfter(thirtyDaysAgo)).toList();
    final attendedCount = monthlyAttList.where((att) => att.isClockedIn || att.clockInTime != null).length;
    
    final attendanceRate = ((attendedCount / 22) * 100).clamp(0, 100).toInt();

    int stars = 5;
    String ratingText = 'Excellent (ممتاز)';
    Color ratingColor = AppColors.success;

    if (attendanceRate >= 90) {
      stars = 5;
      ratingText = 'Excellent (ممتاز)';
      ratingColor = AppColors.success;
    } else if (attendanceRate >= 80) {
      stars = 4;
      ratingText = 'Very Good (جيد جداً)';
      ratingColor = AppColors.teal;
    } else if (attendanceRate >= 70) {
      stars = 3;
      ratingText = 'Good (جيد)';
      ratingColor = AppColors.blue;
    } else {
      stars = 2;
      ratingText = 'Needs Improvement';
      ratingColor = AppColors.warning;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Monthly Performance',
                  style: AppTextStyles.headingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  ratingText,
                  style: AppTextStyles.bodySmall.copyWith(color: ratingColor, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 20.sp,
                  );
                }),
              ),
              SizedBox(width: 8.w),
              Text('$stars.0 / 5.0 Rating', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildEvalCol('Days Attended', '$attendedCount / 22 Days', AppColors.blue),
              _buildEvalCol('Attendance Rate', '$attendanceRate%', ratingColor),
              _buildEvalCol('Adherence', '95%', AppColors.teal),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEvalCol(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final selectedDate = DateTime(_selectedShiftDate.year, _selectedShiftDate.month, _selectedShiftDate.day);
    final todayDate = DateTime(now.year, now.month, now.day);

    final isToday = selectedDate == todayDate;
    final isFuture = selectedDate.isAfter(todayDate);
    final isPast = selectedDate.isBefore(todayDate);

    // Retrieve attendance record corresponding strictly to the selected date
    final selectedDateAtt = _attendanceHistory.where((att) {
      return att.date.year == selectedDate.year &&
          att.date.month == selectedDate.month &&
          att.date.day == selectedDate.day;
    }).firstOrNull ?? (isToday ? _todayAttendance : null);

    final isClockedIn = selectedDateAtt?.isClockedIn ?? false;
    final isClockedOut = selectedDateAtt?.clockOutTime != null;

    bool isShiftCompleted = false;
    if (isPast) {
      isShiftCompleted = selectedDateAtt != null;
    } else if (isToday) {
      if (isClockedOut) {
        isShiftCompleted = true;
      } else if (_schedule != null && _schedule!.activities.isNotEmpty) {
        final lastActEnd = _schedule!.activities.last.endTime;
        if (now.isAfter(lastActEnd) && isClockedIn) {
          isShiftCompleted = true;
        }
      }
    }

    final shiftDateAttendance = selectedDateAtt != null ? [selectedDateAtt] : <AttendanceRecordEntity>[];

    final shiftDateTransitions = _transitions.where((trans) {
      return trans.timestamp.year == selectedDate.year &&
          trans.timestamp.month == selectedDate.month &&
          trans.timestamp.day == selectedDate.day;
    }).toList();

    final currentAct = isToday ? _schedule?.getCurrentActivity(now, isClockedIn: isClockedIn && !isShiftCompleted) : null;
    final nextAct = isToday ? _schedule?.getNextActivity(now, isClockedIn: isClockedIn && !isShiftCompleted) : (isFuture ? _schedule?.activities.firstOrNull : null);
    
    final shiftProgress = isShiftCompleted
        ? 1.0
        : (isToday ? (_schedule?.getShiftProgress(now, isClockedIn: isClockedIn) ?? 0.0) : 0.0);
        
    final latestTransition = shiftDateTransitions.isNotEmpty ? shiftDateTransitions.last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.employee.fullName}\'s Details'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employee Profile Header Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36.r,
                          backgroundColor: AppColors.navy,
                          child: Text(
                            widget.employee.fullName.isNotEmpty ? widget.employee.fullName[0].toUpperCase() : 'E',
                            style: AppTextStyles.headingLarge.copyWith(color: Colors.white, fontSize: 32.sp),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(widget.employee.fullName, style: AppTextStyles.headingMedium),
                        SizedBox(height: 4.h),
                        Text(widget.employee.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          alignment: WrapAlignment.center,
                          children: [
                            Chip(
                              label: Text(widget.employee.role.toUpperCase()),
                              backgroundColor: widget.employee.isManager
                                  ? AppColors.teal.withValues(alpha: 0.15)
                                  : AppColors.blue.withValues(alpha: 0.15),
                            ),
                            Chip(
                              label: Text(widget.employee.departmentName ?? 'Engineering'),
                              backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                            ),
                            Chip(
                              avatar: Icon(
                                isFuture
                                    ? Icons.schedule
                                    : (isShiftCompleted
                                        ? Icons.task_alt
                                        : (isClockedIn ? Icons.check_circle : Icons.warning_amber_rounded)),
                                size: 16,
                                color: isFuture
                                    ? AppColors.blue
                                    : (isShiftCompleted
                                        ? AppColors.success
                                        : (isClockedIn ? AppColors.success : AppColors.warning)),
                              ),
                              label: Text(isFuture
                                  ? 'Upcoming Shift'
                                  : (isShiftCompleted
                                      ? 'Shift Completed'
                                      : (isClockedIn ? 'Clocked In' : 'Not Clocked In Yet'))),
                              backgroundColor: (isFuture
                                      ? AppColors.blue
                                      : (isShiftCompleted || isClockedIn ? AppColors.success : AppColors.warning))
                                  .withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Monthly Employee Performance & Evaluation Card (30 Days)
                  _buildMonthlyEvaluationCard(),
                  SizedBox(height: 20.h),

                  // Interactive Shift Date Selector Bar for Manager
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.blue.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.blue),
                          onPressed: () {
                            final prev = _selectedShiftDate.subtract(const Duration(days: 1));
                            setState(() => _selectedShiftDate = prev);
                            _fetchEmployeeData(_selectedShiftDate);
                          },
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedShiftDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => _selectedShiftDate = picked);
                                _fetchEmployeeData(_selectedShiftDate);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_month, color: AppColors.blue),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    DateFormat('EEEE, MMM d, yyyy').format(_selectedShiftDate),
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.blue),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.blue),
                          onPressed: () {
                            final next = _selectedShiftDate.add(const Duration(days: 1));
                            setState(() => _selectedShiftDate = next);
                            _fetchEmployeeData(_selectedShiftDate);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Current Status & Activity Header
                  _buildSectionHeader('Current Status & Activity', selectedDate),
                  SizedBox(height: 12.h),

                  if (isFuture) ...[
                    // Future Upcoming Shift Card
                    Container(
                      width: double.infinity,
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
                              Row(
                                children: [
                                  const Icon(Icons.event_outlined, color: AppColors.blue, size: 20),
                                  SizedBox(width: 8.w),
                                  Text('UPCOMING SHIFT', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const StatusBadge(status: 'Upcoming'),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Shift Scheduled for ${DateFormat('EEEE, MMM d').format(selectedDate)}',
                            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                          ),
                          if (_schedule != null && _schedule!.activities.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'First Activity: ${_schedule!.activities.first.name} (${DateFormat('hh:mm a').format(_schedule!.activities.first.startTime)})',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else if (isShiftCompleted) ...[
                    // Completed Shift Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF15803D), AppColors.success],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
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
                                  const Icon(Icons.verified, color: Colors.white, size: 20),
                                  SizedBox(width: 8.w),
                                  Text('SHIFT COMPLETED', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const StatusBadge(status: 'Completed'),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '🎉 Shift Has Ended!',
                            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Clock In: ${selectedDateAtt?.clockInTime != null ? DateFormat('hh:mm a').format(selectedDateAtt!.clockInTime!) : '--'}  •  Clock Out: ${selectedDateAtt?.clockOutTime != null ? DateFormat('hh:mm a').format(selectedDateAtt!.clockOutTime!) : DateFormat('hh:mm a').format(now)}',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shift Completion', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                              Text('100%', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: const LinearProgressIndicator(
                              value: 1.0,
                              minHeight: 8,
                              backgroundColor: Colors.white30,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ] else ...[
                    // Active / Waiting Shift Card
                    Container(
                      width: double.infinity,
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
                              Row(
                                children: [
                                  Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: BoxDecoration(
                                      color: isClockedIn ? AppColors.teal : AppColors.warning,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    isClockedIn ? 'CURRENT ACTIVITY' : 'SHIFT STATUS',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              if (currentAct != null && isClockedIn)
                                StatusBadge(status: 'Active'),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            isClockedIn
                                ? (currentAct?.name ?? 'Off-Shift / Unscheduled')
                                : 'Waiting for Attendance Clock-In',
                            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                          ),
                          if (currentAct != null && isClockedIn) ...[
                            SizedBox(height: 6.h),
                            Text(
                              'Time: ${DateFormat('hh:mm a').format(currentAct.startTime)} - ${DateFormat('hh:mm a').format(currentAct.endTime)} (${currentAct.durationMinutes}m)',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                            ),
                          ],
                          if (latestTransition != null && isClockedIn) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Text('Actual Transition: ${latestTransition.actualActivityName}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8.w),
                                StatusBadge(status: latestTransition.adherenceStatus),
                              ],
                            )
                          ],
                          if (nextAct != null) ...[
                            SizedBox(height: 12.h),
                            Text(
                              'Next Activity: ${nextAct.name} (${DateFormat('hh:mm a').format(nextAct.startTime)})',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                            ),
                          ],
                          SizedBox(height: 16.h),
                          // Shift Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shift Progress', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                              Text('${(shiftProgress * 100).toInt()}%', style: AppTextStyles.bodySmall.copyWith(color: AppColors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: shiftProgress,
                              minHeight: 8.h,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),

                  // Shift Date Activity Transitions Log Section
                  _buildSectionHeader('Activity Transitions Log', selectedDate),
                  SizedBox(height: 12.h),

                  if (shiftDateTransitions.isEmpty) ...[
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text('No activity transitions recorded for this shift date.', style: AppTextStyles.bodySmall),
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shiftDateTransitions.length,
                      itemBuilder: (context, index) {
                        final trans = shiftDateTransitions[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8.h),
                          child: ListTile(
                            leading: const Icon(Icons.swap_horiz, color: AppColors.blue),
                            title: Text(
                              'Transition to ${trans.actualActivityName}',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Planned: ${trans.plannedActivityName}  •  ${DateFormat('hh:mm a').format(trans.timestamp)}'),
                            trailing: StatusBadge(status: trans.adherenceStatus),
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 24.h),

                  // Shift Date Attendance Record Section
                  _buildSectionHeader('Attendance Log', selectedDate),
                  SizedBox(height: 12.h),

                  if (shiftDateAttendance.isEmpty) ...[
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text('No attendance record found for this shift date.', style: AppTextStyles.bodySmall),
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shiftDateAttendance.length,
                      itemBuilder: (context, index) {
                        final att = shiftDateAttendance[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8.h),
                          child: ListTile(
                            leading: const Icon(Icons.fingerprint, color: AppColors.blue),
                            title: Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(att.date),
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'In: ${att.clockInTime != null ? DateFormat('hh:mm a').format(att.clockInTime!) : '--'}  •  Out: ${att.clockOutTime != null ? DateFormat('hh:mm a').format(att.clockOutTime!) : '--'}',
                            ),
                            trailing: StatusBadge(status: att.status),
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 24.h),

                  // Planned Schedule Breakdown Section
                  _buildSectionHeader('Planned Schedule', selectedDate),
                  SizedBox(height: 12.h),

                  if (_schedule == null || _schedule!.activities.isEmpty) ...[
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: const Center(child: Text('No shift schedule assigned for this date.')),
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _schedule!.activities.length,
                      itemBuilder: (context, index) {
                        final act = _schedule!.activities[index];
                        final isCur = isToday && isClockedIn && !isShiftCompleted && act.isCurrent(now);
                        final color = _parseColor(act.colorHex);

                        return Card(
                          margin: EdgeInsets.only(bottom: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(
                              color: isCur ? AppColors.error : AppColors.border,
                              width: isCur ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 14.w,
                              height: 14.w,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            title: Text(
                              act.name,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: isCur ? FontWeight.bold : FontWeight.normal),
                            ),
                            subtitle: Text(
                              '${DateFormat('hh:mm a').format(act.startTime)} - ${DateFormat('hh:mm a').format(act.endTime)} (${act.durationMinutes}m)',
                            ),
                            trailing: isCur
                                ? Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10.r)),
                                    child: Text('📍 NOW', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.sp)),
                                  )
                                : Text(act.code, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ),
    );
  }
}
