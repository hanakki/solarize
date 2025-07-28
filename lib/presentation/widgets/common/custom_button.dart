import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';

/// Custom button widget with different styles (primary, secondary, tertiary)
/// Provides consistent button styling throughout the app
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final bool isLoading;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: _getTextStyle(),
                  ),
                ],
              ),
      ),
    );
  }

  /// Get button style based on type
  ButtonStyle _getButtonStyle() {
    switch (style) {
      case CustomButtonStyle.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButtonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 2,
        );
      case CustomButtonStyle.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryButtonColor,
          foregroundColor: AppColors.primaryTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 1,
        );
      case CustomButtonStyle.tertiary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.tertiaryButtonColor,
          foregroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            side: const BorderSide(color: AppColors.primaryColor),
          ),
          elevation: 0,
        );
    }
  }

  /// Get text style based on button type
  TextStyle _getTextStyle() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }
}

/// Enum for button styles
enum CustomButtonStyle {
  primary,
  secondary,
  tertiary,
}
