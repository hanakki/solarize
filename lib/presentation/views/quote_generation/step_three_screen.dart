import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import 'widgets/step_header_widget.dart';
import 'widgets/quote_summary_widget.dart';
import '../../../core/constants/strings.dart';

/// Step 3: Review Quotation & Send to Client
/// Shows final quote summary and export options
class StepThreeScreen extends StatelessWidget {
  const StepThreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteGenerationViewModel>(
      builder: (context, viewModel, child) {
        final stepInfo = viewModel.getStepInfo(3);

        return Column(
          children: [
            // Step header
            StepHeaderWidget(
              title: stepInfo.title,
              description: stepInfo.description,
            ),

            const SizedBox(height: 24),

            // Quote summary
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Quote summary widget
                    if (viewModel.calculationResult != null &&
                        viewModel.projectDetails != null)
                      QuoteSummaryWidget(
                        calculationResult: viewModel.calculationResult!,
                        projectDetails: viewModel.projectDetails!,
                      ),

                    const SizedBox(height: 32),

                    // Action buttons
                    _buildActionButtons(context, viewModel),

                    const SizedBox(height: 24),

                    // Navigation buttons
                    _buildNavigationButtons(viewModel),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build action buttons for export and sharing
  Widget _buildActionButtons(
      BuildContext context, QuoteGenerationViewModel viewModel) {
    return Column(
      children: [
        // Share with client button
        CustomButton(
          text: AppStrings.shareWithClientButton,
          onPressed: () => _shareWithClient(context, viewModel),
          icon: const Icon(Icons.share),
          isLoading: viewModel.isGeneratingPdf,
        ),

        const SizedBox(height: 16),

        // Export as PNG button
        CustomButton(
          text: AppStrings.exportAsPngButton,
          style: CustomButtonStyle.secondary,
          onPressed: () => _exportAsPng(context, viewModel),
          icon: const Icon(Icons.image),
          isLoading: viewModel.isGeneratingImage,
        ),
      ],
    );
  }

  /// Build navigation buttons
  Widget _buildNavigationButtons(QuoteGenerationViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: AppStrings.backButton,
            style: CustomButtonStyle.secondary,
            onPressed: viewModel.previousStep,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: AppStrings.backToHomeButton,
            style: CustomButtonStyle.tertiary,
            onPressed: () => _backToHome(viewModel),
          ),
        ),
      ],
    );
  }

  /// Share quote with client (PDF)
  Future<void> _shareWithClient(
      BuildContext context, QuoteGenerationViewModel viewModel) async {
    try {
      // Create quote first if not exists
      if (viewModel.currentQuote == null) {
        await viewModel.createQuote();
      }

      if (viewModel.currentQuote != null) {
        await viewModel.generatePdf();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quote shared successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share quote: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Export quote as PNG image
  Future<void> _exportAsPng(
      BuildContext context, QuoteGenerationViewModel viewModel) async {
    try {
      // Create quote first if not exists
      if (viewModel.currentQuote == null) {
        await viewModel.createQuote();
      }

      if (viewModel.currentQuote != null) {
        await viewModel.generateImage();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quote exported as image successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate back to home and reset quote generation
  void _backToHome(QuoteGenerationViewModel viewModel) {
    viewModel.resetQuoteGeneration();
    // Navigate to home - implementation depends on navigation structure
  }
}
