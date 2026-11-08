import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/di.dart';
import '../../../../core/reusable_component/empty_state_widget.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../employees/domain/repositories/employee_repository.dart';
import '../../domain/entities/planned_activity_entity.dart';
import '../../domain/entities/planned_schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';

class ScheduleBuilderScreen extends StatefulWidget {
  const ScheduleBuilderScreen({super.key});

  @override
  State<ScheduleBuilderScreen> createState() => _ScheduleBuilderScreenState();
}

class _ScheduleBuilderScreenState extends State<ScheduleBuilderScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<PlannedScheduleEntity> _schedules = [];
  List<UserEntity> _employees = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final companyId =
        context.read<AuthCubit>().currentUser?.companyId ?? 'company_001';
    try {
      final list = await getIt<ScheduleRepository>().getCompanySchedules(
        companyId,
        _selectedDate,
      );
      final emps = await getIt<EmployeeRepository>().getEmployees(companyId);
      setState(() {
        _schedules = list;
        _employees = emps;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchData();
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

  void _confirmDeleteShift(PlannedScheduleEntity shift) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shift'),
        content: Text(
          'Are you sure you want to delete the shift for ${shift.employeeName} on ${DateFormat('MMM d, yyyy').format(shift.date)}?\n\nThis will remove the schedule from Cloud Firestore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);

              await getIt<ScheduleRepository>().deleteSchedule(shift.id);
              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Shift for ${shift.employeeName} deleted from Firestore!',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
              _fetchData();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined),
            tooltip: 'Publish All Shifts',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              for (final s in _schedules) {
                final published = PlannedScheduleEntity(
                  id: s.id,
                  employeeId: s.employeeId,
                  employeeName: s.employeeName,
                  companyId: s.companyId,
                  departmentId: s.departmentId,
                  date: s.date,
                  activities: s.activities,
                  isPublished: true,
                );
                await getIt<ScheduleRepository>().saveSchedule(published);
              }
              _fetchData();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('All shifts published to Firestore!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddShiftDialog,
        backgroundColor: AppColors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Shift', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(
                      () => _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      ),
                    );
                    _fetchData();
                  },
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.blue,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                        style: AppTextStyles.headingSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(
                      () => _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      ),
                    );
                    _fetchData();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Employee Shift List
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : _schedules.isEmpty
                ? const EmptyStateWidget(
                    message: 'No shifts scheduled for this date.',
                    icon: Icons.calendar_month,
                  )
                : ListView.builder(
                    padding: REdgeInsets.only(bottom: 90,top: 16,left: 16,right: 16),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final shift = _schedules[index];
                      final start = shift.activities.isNotEmpty
                          ? DateFormat('hh:mm a')
                                .format(shift.activities.first.startTime)
                          : '09:00 AM';
                      final end = shift.activities.isNotEmpty
                          ? DateFormat('hh:mm a')
                                .format(shift.activities.last.endTime)
                          : '05:00 PM';

                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    shift.employeeName,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(
                                          shift.isPublished
                                              ? 'Published'
                                              : 'Draft',
                                        ),
                                        backgroundColor: shift.isPublished
                                            ? AppColors.success.withValues(
                                                alpha: 0.15,
                                              )
                                            : AppColors.warning.withValues(
                                                alpha: 0.15,
                                              ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        tooltip: 'Delete Shift',
                                        onPressed: () =>
                                            _confirmDeleteShift(shift),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Shift Time: $start - $end',
                                style: AppTextStyles.bodyMedium,
                              ),
                              SizedBox(height: 12.h),

                              // Activities Chips List
                              Wrap(
                                spacing: 6.w,
                                runSpacing: 6.h,
                                children: shift.activities.map((act) {
                                  final c = _parseColor(act.colorHex);
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: c.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: c.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(
                                      '${act.name} (${DateFormat('hh:mm a').format(act.startTime)} - ${DateFormat('hh:mm a').format(act.endTime)})',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: c,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${shift.activities.length} Planned Activities',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _showEditShiftSheet(shift),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text(
                                      'Edit Shift & Activities',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddShiftDialog() {
    UserEntity? selectedEmployee = _employees.isNotEmpty
        ? _employees.first
        : null;
    final nameController = TextEditingController(
      text: selectedEmployee?.fullName ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Shift'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_employees.isNotEmpty) ...[
                  const Text('Select Employee:'),
                  SizedBox(height: 6.h),
                  DropdownButtonFormField<UserEntity>(
                    value: selectedEmployee,
                    items: _employees.map((emp) {
                      return DropdownMenuItem(
                        value: emp,
                        child: Text(
                          '${emp.fullName} (${emp.departmentName ?? 'Dept'})',
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedEmployee = val;
                          nameController.text = val.fullName;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Employee Name'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    final companyId =
                        context.read<AuthCubit>().currentUser?.companyId ??
                        'company_001';
                    final y = _selectedDate.year;
                    final m = _selectedDate.month;
                    final d = _selectedDate.day;

                    final newSchedule = PlannedScheduleEntity(
                      id: 'sched_${selectedEmployee?.id ?? DateTime.now().millisecondsSinceEpoch}_${_selectedDate.millisecondsSinceEpoch}',
                      employeeId:
                          selectedEmployee?.id ??
                          'emp_${DateTime.now().millisecondsSinceEpoch}',
                      employeeName: nameController.text.trim(),
                      companyId: companyId,
                      departmentId:
                          selectedEmployee?.departmentId ?? 'dept_001',
                      date: _selectedDate,
                      activities: [
                        PlannedActivityEntity(
                          id: 'act_1',
                          name: 'Morning Work Session',
                          code: 'WORK',
                          colorHex: '#3B82F6',
                          iconName: 'work',
                          startTime: DateTime(y, m, d, 9, 0),
                          endTime: DateTime(y, m, d, 13, 0),
                          durationMinutes: 240,
                        ),
                        PlannedActivityEntity(
                          id: 'act_2',
                          name: 'Lunch Break',
                          code: 'LUNCH',
                          colorHex: '#F59E0B',
                          iconName: 'restaurant',
                          startTime: DateTime(y, m, d, 13, 0),
                          endTime: DateTime(y, m, d, 14, 0),
                          durationMinutes: 60,
                        ),
                        PlannedActivityEntity(
                          id: 'act_3',
                          name: 'Afternoon Work Session',
                          code: 'WORK',
                          colorHex: '#3B82F6',
                          iconName: 'work',
                          startTime: DateTime(y, m, d, 14, 0),
                          endTime: DateTime(y, m, d, 17, 0),
                          durationMinutes: 180,
                        ),
                      ],
                      isPublished: true,
                    );

                    final navigator = Navigator.of(ctx);
                    await getIt<ScheduleRepository>().saveSchedule(newSchedule);
                    if (mounted) navigator.pop();
                    _fetchData();
                  }
                },
                child: const Text('Create & Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditShiftSheet(PlannedScheduleEntity shift) {
    bool isPublished = shift.isPublished;
    final List<PlannedActivityEntity> activities = List.from(shift.activities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Shift: ${shift.employeeName}',
                        style: AppTextStyles.headingSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  SwitchListTile(
                    title: const Text('Publish Shift'),
                    value: isPublished,
                    onChanged: (val) => setSheetState(() => isPublished = val),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Planned Activities (${activities.length})',
                        style: AppTextStyles.labelMedium,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.more_time, size: 18),
                        label: const Text('Add Activity'),
                        onPressed: () {
                          _showActivityFormDialog(
                            context: context,
                            shiftDate: shift.date,
                            onSave: (newAct) {
                              setSheetState(() {
                                activities.add(newAct);
                                activities.sort(
                                  (a, b) => a.startTime.compareTo(b.startTime),
                                );
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 250.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: activities.length,
                      itemBuilder: (context, actIdx) {
                        final act = activities[actIdx];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8.h),
                          child: ListTile(
                            leading: Container(
                              width: 14.w,
                              height: 14.w,
                              decoration: BoxDecoration(
                                color: _parseColor(act.colorHex),
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              act.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${DateFormat('hh:mm a').format(act.startTime)} - ${DateFormat('hh:mm a').format(act.endTime)} (${act.durationMinutes}m)',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: AppColors.blue,
                                  ),
                                  onPressed: () {
                                    _showActivityFormDialog(
                                      context: context,
                                      shiftDate: shift.date,
                                      initialActivity: act,
                                      onSave: (updatedAct) {
                                        setSheetState(() {
                                          activities[actIdx] = updatedAct;
                                          activities.sort(
                                            (a, b) => a.startTime.compareTo(
                                              b.startTime,
                                            ),
                                          );
                                        });
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setSheetState(
                                      () => activities.removeAt(actIdx),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirmDeleteShift(shift);
                          },
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Delete Shift'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          onPressed: () async {
                            final updated = PlannedScheduleEntity(
                              id: shift.id,
                              employeeId: shift.employeeId,
                              employeeName: shift.employeeName,
                              companyId: shift.companyId,
                              departmentId: shift.departmentId,
                              date: shift.date,
                              activities: activities,
                              isPublished: isPublished,
                            );

                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(ctx);

                            await getIt<ScheduleRepository>().saveSchedule(
                              updated,
                            );
                            if (mounted) {
                              navigator.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Shift for ${shift.employeeName} updated in Firestore!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                            _fetchData();
                          },
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showActivityFormDialog({
    required BuildContext context,
    required DateTime shiftDate,
    PlannedActivityEntity? initialActivity,
    required Function(PlannedActivityEntity) onSave,
  }) {
    final nameController = TextEditingController(
      text: initialActivity?.name ?? 'New Task',
    );
    String selectedCode = initialActivity?.code ?? 'WORK';
    String selectedColorHex = initialActivity?.colorHex ?? '#3B82F6';

    TimeOfDay startTime = initialActivity != null
        ? TimeOfDay.fromDateTime(initialActivity.startTime)
        : const TimeOfDay(hour: 9, minute: 0);

    TimeOfDay endTime = initialActivity != null
        ? TimeOfDay.fromDateTime(initialActivity.endTime)
        : const TimeOfDay(hour: 11, minute: 0);

    final colorOptions = [
      {'name': 'Blue', 'hex': '#3B82F6', 'color': AppColors.blue},
      {'name': 'Teal', 'hex': '#14B8A6', 'color': AppColors.teal},
      {'name': 'Amber', 'hex': '#F59E0B', 'color': AppColors.warning},
      {'name': 'Pink', 'hex': '#EC4899', 'color': const Color(0xFFEC4899)},
      {'name': 'Purple', 'hex': '#8B5CF6', 'color': const Color(0xFF8B5CF6)},
    ];

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            title: Text(
              initialActivity != null
                  ? 'Edit Activity Time'
                  : 'Add Activity Time',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Activity Name',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text('Activity Code:', style: AppTextStyles.bodySmall),
                  DropdownButtonFormField<String>(
                    value: selectedCode,
                    items: const [
                      DropdownMenuItem(
                        value: 'WORK',
                        child: Text('WORK (Work Session)'),
                      ),
                      DropdownMenuItem(
                        value: 'BREAK',
                        child: Text('BREAK (Coffee Break)'),
                      ),
                      DropdownMenuItem(
                        value: 'LUNCH',
                        child: Text('LUNCH (Lunch Break)'),
                      ),
                      DropdownMenuItem(
                        value: 'MEETING',
                        child: Text('MEETING (Team Sync)'),
                      ),
                      DropdownMenuItem(
                        value: 'TRAINING',
                        child: Text('TRAINING (Session)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedCode = val);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Start Time Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start Time:'),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(startTime.format(context)),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (picked != null) {
                            setDlgState(() => startTime = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // End Time Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('End Time:'),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(endTime.format(context)),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (picked != null) {
                            setDlgState(() => endTime = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Color Picker
                  Text('Color Badge:', style: AppTextStyles.bodySmall),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: colorOptions.map((opt) {
                      final hex = opt['hex'] as String;
                      final c = opt['color'] as Color;
                      final isSel = selectedColorHex == hex;
                      return GestureDetector(
                        onTap: () => setDlgState(() => selectedColorHex = hex),
                        child: Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSel
                                ? Border.all(color: Colors.black, width: 2.5)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    final y = shiftDate.year;
                    final m = shiftDate.month;
                    final d = shiftDate.day;

                    final startDt = DateTime(
                      y,
                      m,
                      d,
                      startTime.hour,
                      startTime.minute,
                    );
                    final endDt = DateTime(
                      y,
                      m,
                      d,
                      endTime.hour,
                      endTime.minute,
                    );
                    final duration = endDt.difference(startDt).inMinutes;

                    final activity = PlannedActivityEntity(
                      id:
                          initialActivity?.id ??
                          'act_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      code: selectedCode,
                      colorHex: selectedColorHex,
                      iconName: selectedCode == 'BREAK'
                          ? 'coffee'
                          : (selectedCode == 'LUNCH'
                                ? 'restaurant'
                                : (selectedCode == 'MEETING'
                                      ? 'groups'
                                      : 'work')),
                      startTime: startDt,
                      endTime: endDt,
                      durationMinutes: duration > 0 ? duration : 30,
                    );

                    onSave(activity);
                    Navigator.pop(dCtx);
                  }
                },
                child: const Text('Save Activity'),
              ),
            ],
          );
        },
      ),
    );
  }
}
