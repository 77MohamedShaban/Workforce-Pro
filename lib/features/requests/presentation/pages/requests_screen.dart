import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/empty_state_widget.dart';
import '../../../../core/reusable_component/status_badge.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../domain/entities/request_entity.dart';
import '../cubit/request_cubit.dart';
import '../cubit/request_state.dart';

class RequestsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String companyId;
  final bool isManager;

  const RequestsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.companyId,
    required this.isManager,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  @override
  void didUpdateWidget(covariant RequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isManager != widget.isManager || oldWidget.userId != widget.userId) {
      _fetchRequests();
    }
  }

  void _fetchRequests() {
    if (widget.isManager) {
      context.read<RequestCubit>().loadCompanyRequests(widget.companyId);
    } else {
      context.read<RequestCubit>().loadEmployeeRequests(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isManager ? 'All Employee Requests' : 'requests'.tr()),
      ),
      floatingActionButton: !widget.isManager
          ? FloatingActionButton.extended(
              onPressed: () => _showNewRequestDialog(context),
              backgroundColor: AppColors.blue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('create_request'.tr(), style: const TextStyle(color: Colors.white)),
            )
          : null,
      body: BlocBuilder<RequestCubit, RequestState>(
        builder: (context, state) {
          if (state is RequestLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RequestLoaded) {
            if (state.requests.isEmpty) {
              return EmptyStateWidget(
                message: widget.isManager
                    ? 'No requests submitted by employees yet'
                    : 'No requests submitted yet',
                icon: Icons.assignment_outlined,
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final req = state.requests[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.type,
                                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (widget.isManager) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Employee: ${req.employeeName}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            StatusBadge(status: req.status),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          req.reason,
                          style: AppTextStyles.bodyMedium,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textMuted),
                                SizedBox(width: 4.w),
                                Text(
                                  DateFormat('MMM d, yyyy').format(req.date),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            Text(
                              'Submitted: ${DateFormat('MMM d').format(req.createdAt)}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        if (req.managerNotes != null && req.managerNotes!.isNotEmpty) ...[
                          const Divider(height: 16),
                          Text(
                            'Manager Note: ${req.managerNotes}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        // Manager Decision Actions (Only visible to Manager for Pending requests)
                        if (widget.isManager && req.isPending) ...[
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                onPressed: () => _showDecisionDialog(context, req, isApprove: false),
                                child: const Text('Reject'),
                              ),
                              SizedBox(width: 8.w),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                onPressed: () => _showDecisionDialog(context, req, isApprove: true),
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
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

  void _showDecisionDialog(BuildContext context, RequestEntity request, {required bool isApprove}) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isApprove ? 'Approve Request' : 'Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request from: ${request.employeeName} (${request.type})'),
            SizedBox(height: 12.h),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Manager Note (Optional)',
                hintText: 'Add a note for the employee...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? AppColors.success : AppColors.error,
            ),
            onPressed: () {
              final status = isApprove ? AppConstants.statusApproved : AppConstants.statusRejected;
              final notes = notesController.text.trim().isNotEmpty
                  ? notesController.text.trim()
                  : (isApprove ? 'Approved by Manager' : 'Rejected by Manager');

              context.read<RequestCubit>().updateStatus(request.id, status, managerNotes: notes);
              Navigator.pop(ctx);
            },
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _showNewRequestDialog(BuildContext context) {
    String selectedType = AppConstants.requestPto;
    final reasonController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('create_request'.tr(), style: AppTextStyles.headingSmall),
                  SizedBox(height: 16.h),
                  Text('request_type'.tr(), style: AppTextStyles.labelMedium),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: AppConstants.requestTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16.h),

                  // Interactive Request Date Picker
                  Text('Request Date', style: AppTextStyles.labelMedium),
                  SizedBox(height: 8.h),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48.h),
                      alignment: Alignment.centerLeft,
                    ),
                    icon: const Icon(Icons.calendar_today, size: 18, color: AppColors.blue),
                    label: Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                      style: AppTextStyles.bodyMedium,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  SizedBox(height: 16.h),

                  Text('reason'.tr(), style: AppTextStyles.labelMedium),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Provide details for your request...',
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                    onPressed: () {
                      if (reasonController.text.trim().isEmpty) return;
                      final request = RequestEntity(
                        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                        employeeId: widget.userId,
                        employeeName: widget.userName,
                        companyId: widget.companyId,
                        type: selectedType,
                        reason: reasonController.text.trim(),
                        date: selectedDate,
                        status: AppConstants.statusPending,
                        createdAt: DateTime.now(),
                      );
                      context.read<RequestCubit>().submitRequest(request);
                      Navigator.pop(context);
                    },
                    child: Text('submit'.tr()),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
