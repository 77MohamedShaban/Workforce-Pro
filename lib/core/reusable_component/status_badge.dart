import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_constants.dart';
import '../utils/theme/app_colors.dart';
import '../utils/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getBackgroundColor() {
    switch (status) {
      case AppConstants.statusApproved:
      case AppConstants.adherenceOnTime:
        return AppColors.success.withValues(alpha: 0.15);
      case AppConstants.statusPending:
      case AppConstants.adherenceLate:
        return AppColors.warning.withValues(alpha: 0.15);
      case AppConstants.statusRejected:
      case AppConstants.adherenceEarly:
        return AppColors.error.withValues(alpha: 0.15);
      case AppConstants.statusCancelled:
      case AppConstants.adherenceUnplanned:
      default:
        return AppColors.textMuted.withValues(alpha: 0.15);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case AppConstants.statusApproved:
      case AppConstants.adherenceOnTime:
        return AppColors.success;
      case AppConstants.statusPending:
      case AppConstants.adherenceLate:
        return AppColors.warning;
      case AppConstants.statusRejected:
      case AppConstants.adherenceEarly:
        return AppColors.error;
      case AppConstants.statusCancelled:
      case AppConstants.adherenceUnplanned:
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
