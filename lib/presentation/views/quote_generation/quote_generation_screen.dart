import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/white_content_container.dart';
import 'widgets/progress_indicator_widget.dart';
import 'step_one_screen.dart';
import 'step_two_screen.dart';
import 'step_three_screen.dart';

/// Main quote generation screen that manages the 3-step process
/// Acts as a container for the step screens with progress indicator
class QuoteGenerationScreen extends StatelessWidget {
  const QuoteGenerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Consumer<QuoteGenerationViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Custom app bar
                CustomAppBar(
                  title: 'Generate Quote',
                  onBackPressed: () {
                    if (viewModel.currentStep > 1) {
                      viewModel.previousStep();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),

                // Step content
                Expanded(
                  child: WhiteContentContainer(
                    topMargin: 0,
                    child: Column(
                      children: [
                        // Progress indicator
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ProgressIndicatorWidget(
                            currentStep: viewModel.currentStep,
                            totalSteps: 3,
                            getProgressState: viewModel.getProgressState,
                          ),
                        ),

                        // Step content
                        Expanded(
                          child: _buildStepContent(viewModel.currentStep),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build content for current step
  Widget _buildStepContent(int currentStep) {
    switch (currentStep) {
      case 1:
        return const StepOneScreen();
      case 2:
        return const StepTwoScreen();
      case 3:
        return const StepThreeScreen();
      default:
        return const StepOneScreen();
    }
  }
}
