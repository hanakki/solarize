import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';

/// White rounded container that appears "above" the background
/// Creates the layered paper effect described in the requirements
class WhiteContentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? topMargin;

  const WhiteContentContainer({
    super.key,
    required this.child,
    this.padding,
    this.topMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: topMargin ?? 100), // Show background at top
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadiusMedium * 2),
          topRight: Radius.circular(AppConstants.borderRadiusMedium * 2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding:
            padding ?? const EdgeInsets.all(AppConstants.defaultPaddingBig),
        child: child,
      ),
    );
  }
}
