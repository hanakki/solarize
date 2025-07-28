import 'package:flutter/material.dart';
import '../../../../core/constants/typography.dart';

/// Widget for displaying the current date in a formatted way
/// Shows date in "Monday • July 7" format
class DateDisplayWidget extends StatelessWidget {
  final String formattedDate;

  const DateDisplayWidget({
    super.key,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedDate,
      style: AppTypography.interRegular22_20_0_black,
    );
  }
}
