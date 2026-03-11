import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool isVisibility;
  final VoidCallback? onVisibilityToggle;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.isVisibility = false,
    this.onVisibilityToggle,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColor.textHint,
      obscureText: isPassword ? isVisibility : false,
      keyboardType: keyboardType,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColor.textHint,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.all(12),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) return AppColor.error;
          if (states.contains(WidgetState.focused)) return AppColor.secondary;
          return AppColor.textHint;
        }),
        suffixIcon: isPassword
            ? InkWell(
                onTap: onVisibilityToggle,
                child: Icon(
                  size: 20,
                  isVisibility ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null,
        suffixIconColor: isPassword
            ? WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.error)) {
                  return AppColor.error;
                }
                if (states.contains(WidgetState.focused)) {
                  return AppColor.secondary;
                }
                return AppColor.textHint;
              })
            : null,
        filled: !enabled || readOnly,
        fillColor: (!enabled || readOnly) ? AppColor.backgroundLight : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: enabled
                ? AppColor.textHint
                : AppColor.textHint.withOpacity(0.5),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.textHint.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.secondary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.error),
        ),
        errorStyle: const TextStyle(
          color: AppColor.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
    );
  }
}
