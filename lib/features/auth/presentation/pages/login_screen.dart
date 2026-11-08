import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/custom_button.dart';
import '../../../../core/reusable_component/custom_text_form_field.dart';
import '../../../../core/routes_manager/routes_name.dart';
import '../../../../core/utils/app_validator.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, RoutesName.mainLayout);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: const BoxDecoration(
                          color: AppColors.navy,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.work_history, size: 48.sp, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: Text(
                        'Workforce Pro',
                        style: AppTextStyles.headingLarge.copyWith(color: AppColors.navy),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        'welcome'.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Text('email'.tr(), style: AppTextStyles.labelMedium),
                    SizedBox(height: 8.h),
                    CustomTextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      hintText: 'email'.tr(),
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: AppValidator.validateEmail,
                    ),
                    SizedBox(height: 20.h),
                    Text('password'.tr(), style: AppTextStyles.labelMedium),
                    SizedBox(height: 8.h),
                    CustomTextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      hintText: 'password'.tr(),
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: AppValidator.validatePassword,
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, RoutesName.forgotPassword);
                        },
                        child: Text(
                          'forgot_password'.tr(),
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.blue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    CustomButton(
                      text: 'login'.tr(),
                      isLoading: isLoading,
                      onPressed: () => _onLoginPressed(context),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('dont_have_account'.tr(), style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RoutesName.signup);
                          },
                          child: Text(
                            'signup'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
