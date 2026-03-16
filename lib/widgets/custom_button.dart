import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final String? iconAsset;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? overlayColor;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.iconAsset,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.overlayColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              clipBehavior: Clip.antiAlias,
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: backgroundColor,
                overlayColor:
                    overlayColor ??
                    (textColor ?? borderColor ?? AppColor.textHint).withAlpha(
                      20,
                    ),
                side: BorderSide(
                  color: borderColor ?? backgroundColor ?? AppColor.textHint,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColor.textHint,
                        strokeWidth: 2,
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (iconAsset != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              iconAsset!,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor ?? AppColor.textHint,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            )
          : ElevatedButton(
              clipBehavior: Clip.antiAlias,
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppColor.secondary,
                overlayColor:
                    overlayColor ??
                    (textColor ?? AppColor.surface).withAlpha(24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColor.surface,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor ?? AppColor.surface,
                      ),
                    ),
            ),
    );
  }
}
