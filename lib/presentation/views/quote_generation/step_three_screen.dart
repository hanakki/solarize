import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import 'widgets/step_header_widget.dart';
import 'widgets/pdf_preview_widget.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/pdf_service.dart';

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
            StepHeaderWidget(
              title: stepInfo.title,
              description: stepInfo.description,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PdfPreviewWidget(
                      pdfFile: viewModel.generatedPdfFile,
                      isLoading: viewModel.isGeneratingPdf,
                      errorMessage: viewModel.errorMessage,
                    ),
                    const SizedBox(height: 32),
                    _buildActionButtons(context, viewModel),
                    const SizedBox(height: 8),
                    _buildNavigationButtons(context, viewModel),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build action buttons for export and sharing
  Widget _buildActionButtons(
      BuildContext context, QuoteGenerationViewModel viewModel) {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.shareWithClientButton,
          onPressed: () => _shareWithClient(context, viewModel),
          isLoading: viewModel.isGeneratingPdf,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: AppStrings.exportAsPngButton,
          style: CustomButtonStyle.secondary,
          onPressed: () => _savePdf(context, viewModel),
          isLoading: viewModel.isGeneratingPdf,
        ),
      ],
    );
  }

  // Build navigation buttons
  Widget _buildNavigationButtons(
      BuildContext context, QuoteGenerationViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: AppStrings.backButton,
            style: CustomButtonStyle.tertiary,
            onPressed: viewModel.previousStep,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'BACK TO HOME',
            style: CustomButtonStyle.tertiary,
            onPressed: () => _backToHome(context, viewModel),
          ),
        ),
      ],
    );
  }

  // Share quote with client (PDF)
  Future<void> _shareWithClient(
      BuildContext context, QuoteGenerationViewModel viewModel) async {
    try {
      if (viewModel.currentQuote == null) {
        await viewModel.createQuote();
      }

      if (viewModel.currentQuote != null) {
        final success = await viewModel.sharePdf();
        if (success && context.mounted) {
          viewModel.resetQuoteGeneration();
          Navigator.pop(context);
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

  // Save PDF to device
  Future<void> _savePdf(
      BuildContext context, QuoteGenerationViewModel viewModel) async {
    try {
      if (viewModel.currentQuote == null) {
        await viewModel.createQuote();
      }

      if (viewModel.currentQuote != null) {
        await viewModel.generatePdf();

        if (context.mounted && viewModel.generatedPdfFile != null) {
          final userFriendlyPath =
              PdfService.getUserFriendlyPath(viewModel.generatedPdfFile!.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('PDF saved successfully!\nLocation: $userFriendlyPath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  viewModel.resetQuoteGeneration();
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _backToHome(BuildContext context, QuoteGenerationViewModel viewModel) {
    viewModel.resetQuoteGeneration();
    Navigator.pop(context);
  }
}
