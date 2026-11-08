import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/theme/app_colors.dart';
import '../utils/theme/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.sp, color: AppColors.textMuted),
            SizedBox(height: 16.h),
            Text(
              message ?? 'no_data'.tr(),
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
