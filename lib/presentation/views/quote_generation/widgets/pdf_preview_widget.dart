import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../widgets/common/custom_button.dart';

/// Widget for previewing and managing generated PDFs
class PdfPreviewWidget extends StatelessWidget {
  final File? pdfFile;
  final bool isLoading;
  final VoidCallback? onGeneratePdf;
  final VoidCallback? onSharePdf;
  final String? errorMessage;

  const PdfPreviewWidget({
    super.key,
    this.pdfFile,
    this.isLoading = false,
    this.onGeneratePdf,
    this.onSharePdf,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(
          Icons.picture_as_pdf,
          color: AppColors.primaryColor,
          size: 24,
        ),
        SizedBox(width: 8),
        Text(
          'PDF Quotation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (pdfFile == null || !pdfFile!.existsSync()) {
      return _buildEmptyState();
    }

    return _buildPdfPreview();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating PDF...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.errorColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Error Generating PDF',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: const TextStyle(
              color: AppColors.errorColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'PDF will be regenerated automatically when you return to this step.',
            style: TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 48,
              color: AppColors.secondaryTextColor,
            ),
            SizedBox(height: 16),
            Text(
              'PDF Will Auto-Generate',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your PDF will be generated automatically when you enter this step',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPreview() {
    return Column(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PdfPreview(
              build: (format) => _buildPdfDocument(),
              canChangePageFormat: false,
              canChangeOrientation: false,
              maxPageWidth: 400,
              actions: const [],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Share PDF',
                style: CustomButtonStyle.primary,
                onPressed: onSharePdf,
                icon: const Icon(Icons.share),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<Uint8List> _buildPdfDocument() async {
    if (pdfFile != null && pdfFile!.existsSync()) {
      // Read the actual generated PDF file
      return await pdfFile!.readAsBytes();
    } else {
      // Fallback to placeholder if no PDF file exists
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Text(
              'PDF Preview\n(Generated PDF will be displayed here)',
              style: const pw.TextStyle(fontSize: 16),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      );
      return pdf.save();
    }
  }
}
