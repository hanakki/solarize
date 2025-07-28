import 'package:flutter/material.dart';
import '../../../viewmodels/quote_generation_viewmodel.dart';

/// Widget for displaying step progress in quote generation
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step numbers
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final progressState = getProgressState(stepNumber);

              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStepColor(progressState),
                        border: Border.all(
                          color: _getStepBorderColor(progressState),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: progressState == ProgressState.completed
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                stepNumber.toString(),
                                style: TextStyle(
                                  color: _getStepTextColor(progressState),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    // Connector line (except for last step)
                    if (stepNumber < totalSteps)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: _getConnectorColor(progressState),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Step labels
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final progressState = getProgressState(stepNumber);

              return Expanded(
                child: Text(
                  _getStepLabel(stepNumber),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStepTextColor(progressState),
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getStepColor(ProgressState state) {
    switch (state) {
      case ProgressState.completed:
        return Colors.green;
      case ProgressState.active:
        return Colors.blue;
      case ProgressState.inactive:
        return Colors.grey.shade300;
    }
  }

  Color _getStepBorderColor(ProgressState state) {
    switch (state) {
      case ProgressState.completed:
        return Colors.green;
      case ProgressState.active:
        return Colors.blue;
      case ProgressState.inactive:
        return Colors.grey.shade400;
    }
  }

  Color _getStepTextColor(ProgressState state) {
    switch (state) {
      case ProgressState.completed:
        return Colors.white;
      case ProgressState.active:
        return Colors.white;
      case ProgressState.inactive:
        return Colors.grey.shade600;
    }
  }

  Color _getConnectorColor(ProgressState state) {
    return state == ProgressState.completed
        ? Colors.green
        : Colors.grey.shade300;
  }

  String _getStepLabel(int step) {
    switch (step) {
      case 1:
        return 'Calculate';
      case 2:
        return 'Details';
      case 3:
        return 'Generate';
      default:
        return 'Step $step';
    }
  }
}
