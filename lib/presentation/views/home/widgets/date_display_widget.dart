import 'package:flutter/material.dart';
import '../../../../core/constants/typography.dart';

// for displaying the current date in a formatted way
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
      style: AppTypography.interRegularBlack22_20_0,
    );
  }
}
