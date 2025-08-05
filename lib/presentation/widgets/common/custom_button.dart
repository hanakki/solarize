import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/typography.dart';

/// Custom button widget with different styles (primary, secondary, tertiary)
/// Provides consistent button styling throughout the app
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final bool isLoading;
  final Widget? icon;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.textStyle,
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
                    style: textStyle ?? _getTextStyle(),
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
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          // textStyle: AppTypography.interSemiBoldWhite14_16_15,
          elevation: 2,
        );
      case CustomButtonStyle.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // transparent fill
          foregroundColor: AppColors.primaryDarkColor, // blue text
          side: const BorderSide(
            color: AppColors.primaryDarkColor,
            width: 2.5, // stroke width
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall), // smaller radius
          ),
          // textStyle: AppTypography.interSemiBoldBlue14_16_15,
          elevation: 0, // no shadow for transparent buttons
        );

      case CustomButtonStyle.tertiary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // no background
          elevation: 0, // no shadow
          shadowColor: Colors.transparent, // suppress elevation shadow
          surfaceTintColor: Colors.transparent, // avoid material tint
          foregroundColor: AppColors.primaryColor, // text color
          padding: EdgeInsets.zero, // optional: link feel
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // no border radius
            side: BorderSide(color: Colors.transparent), // no visible border
          ),
        );
    }
  }

  /// Get text style based on button type
  TextStyle _getTextStyle() {
    switch (style) {
      case CustomButtonStyle.primary:
        return AppTypography.interSemiBoldWhite14_16_15;
      case CustomButtonStyle.secondary:
        return AppTypography.interSemiBoldBlue14_16_15;
      case CustomButtonStyle.tertiary:
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        );
    }
  }
}

/// Enum for button styles
enum CustomButtonStyle {
  primary,
  secondary,
  tertiary,
}
