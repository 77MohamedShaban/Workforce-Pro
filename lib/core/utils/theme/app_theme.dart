import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.mainLight,
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.mainLight),
    dividerTheme: DividerThemeData(color: AppColors.mainLight, thickness: 1.h),
    colorScheme: ColorScheme.light(
      primary: AppColors.mainLight,
    ),
    textTheme: TextTheme(
      bodyLarge: AppTextStyles.regular16White,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.mainDark,
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.mainDark),
    dividerTheme: DividerThemeData(color: AppColors.mainDark, thickness: 1.h),
    colorScheme: ColorScheme.dark(
      primary: AppColors.mainDark,
    ),
    textTheme: TextTheme(
      bodyLarge: AppTextStyles.regular16White.copyWith(color: AppColors.mainDark),
    ),
  );
}
