import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final bool isConfirmPassword;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.textInputAction,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.validator,
    this.isConfirmPassword = false,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomTextFormField> {
  late bool isShowPassword = widget.isPassword;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return TextFormField(
      focusNode: _focusNode,
      enableInteractiveSelection: !widget.isConfirmPassword,
      autocorrect: !widget.isPassword,
      enableSuggestions: !widget.isPassword,
      controller: widget.controller,
      onTapUpOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onFieldSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: isShowPassword,
      style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 18.sp, fontWeight: FontWeight.w500, color: theme.colorScheme.primary),
      decoration: InputDecoration(
        prefixIcon: Padding(
            padding: REdgeInsetsDirectional.only(start: 16, end: 8),
            child: widget.prefixIcon),
        prefixIconColor: theme.colorScheme.onPrimary,
        prefixIconConstraints: BoxConstraints(maxHeight: 40.h, maxWidth: 50.w),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isShowPassword = !isShowPassword;
                  });
                },
                icon: Icon(
                  !isShowPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              )
            : widget.suffixIcon,
        suffixIconColor: theme.colorScheme.onPrimary,
        hintText: widget.hintText,
        hintStyle: theme.textTheme.bodySmall,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: theme.colorScheme.onPrimary,
            width: 1,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.onPrimary,
      ),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
