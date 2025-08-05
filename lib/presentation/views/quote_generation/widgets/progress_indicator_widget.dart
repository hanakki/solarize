import 'package:flutter/material.dart';
import '../../../viewmodels/quote_generation_viewmodel.dart';
import '../../../../core/constants/colors.dart';

// for displaying step progress in quote generation
class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final ProgressState Function(int step) getProgressState;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.getProgressState,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          _getProgressIcon(getProgressState(1)),
          width: 25,
          height: 25,
        ),
        if (totalSteps > 1) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 2,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            _getProgressIcon(getProgressState(2)),
            width: 25,
            height: 25,
          ),
        ],
        if (totalSteps > 2) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 2,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            _getProgressIcon(getProgressState(3)),
            width: 25,
            height: 25,
          ),
        ],
      ],
    );
  }

  String _getProgressIcon(ProgressState state) {
    switch (state) {
      case ProgressState.completed:
        return 'assets/icons/ProgressDone.png';
      case ProgressState.active:
        return 'assets/icons/ProgressActive.png';
      case ProgressState.inactive:
        return 'assets/icons/ProgressDisabled.png';
    }
  }
}
