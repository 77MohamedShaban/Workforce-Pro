import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'font_weight_helper.dart';

abstract class AppTextStyles {
  // Headings
  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle headingMedium = GoogleFonts.inter(
    fontSize: 20.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColors.textPrimary,
  );

  static TextStyle headingSmall = GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColors.textPrimary,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.textSecondary,
  );

  // Labels & Buttons
  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: Colors.white,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColors.textSecondary,
  );

  // Legacy compatibility
  static TextStyle regular16White = bodyLarge.copyWith(color: Colors.white);
}
