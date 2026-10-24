import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'font_weight_helper.dart';

abstract class AppTextStyles {
  // Existing Styles
  static TextStyle regular16White = GoogleFonts.afacadFlux(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.mainLight,
  );

}
