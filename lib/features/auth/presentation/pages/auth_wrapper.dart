import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../main_layout/presentation/pages/main_layout_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const MainLayoutScreen();
        } else if (state is Unauthenticated) {
          return const LoginScreen();
        }

        // Splash / Initial Loading Screen while verifying persistent session
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: const BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.work_history, size: 56.sp, color: Colors.white),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Workforce Pro',
                  style: AppTextStyles.headingLarge.copyWith(color: AppColors.navy),
                ),
                SizedBox(height: 24.h),
                const CircularProgressIndicator(color: AppColors.blue),
              ],
            ),
          ),
        );
      },
    );
  }
}
