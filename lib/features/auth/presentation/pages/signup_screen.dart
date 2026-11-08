import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/reusable_component/custom_button.dart';
import '../../../../core/reusable_component/custom_text_form_field.dart';
import '../../../../core/routes_manager/routes_name.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/app_validator.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();
  String _selectedRole = AppConstants.roleEmployee;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _onSignupPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _fullNameController.text.trim(),
            role: _selectedRole,
            companyName: _companyController.text.trim().isNotEmpty
                ? _companyController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('create_account'.tr()),
      ),
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('full_name'.tr(), style: AppTextStyles.labelMedium),
                    SizedBox(height: 8.h),
                    CustomTextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      hintText: 'full_name'.tr(),
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: AppValidator.validateRequired,
                    ),
                    SizedBox(height: 16.h),
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
                    SizedBox(height: 16.h),
                    Text('password'.tr(), style: AppTextStyles.labelMedium),
                    SizedBox(height: 8.h),
                    CustomTextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      hintText: 'password'.tr(),
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: AppValidator.validatePassword,
                    ),
                    SizedBox(height: 16.h),
                    Text('select_role'.tr(), style: AppTextStyles.labelMedium),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('employee'.tr()),
                            value: AppConstants.roleEmployee,
                            groupValue: _selectedRole,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRole = val);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('manager'.tr()),
                            value: AppConstants.roleManager,
                            groupValue: _selectedRole,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRole = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text('company_name'.tr(), style: AppTextStyles.labelMedium),
                    SizedBox(height: 8.h),
                    CustomTextFormField(
                      controller: _companyController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      hintText: 'company_name'.tr(),
                      prefixIcon: const Icon(Icons.business_outlined),
                    ),
                    SizedBox(height: 32.h),
                    CustomButton(
                      text: 'create_account'.tr(),
                      isLoading: isLoading,
                      onPressed: () => _onSignupPressed(context),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('already_have_account'.tr(), style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'login'.tr(),
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
