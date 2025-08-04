import 'package:flutter/material.dart';
import '../../../../core/constants/typography.dart';

/// Widget for displaying step header with title and description
class StepHeaderWidget extends StatelessWidget {
  final String title;
  final String description;

  const StepHeaderWidget({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.interSemiBoldBlack16_24_0,
        ),
        Text(
          description,
          style: AppTypography.interRegularGray12_16_04,
        ),
      ],
    );
  }
}
