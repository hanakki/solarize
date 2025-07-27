import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/company_profile_model.dart';

/// Service class for generating PDF documents
/// Creates professional quotation PDFs with company branding
class PdfService {
  
  /// Generate a PDF quotation document
  static Future<File> generateQuotePdf(
    QuoteModel quote,
    CompanyProfileModel? companyProfile,
  ) async {
    final pdf = pw.Document();
    
    // Add pages to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(companyProfile),
            pw.SizedBox(height: 20),
            _buildQuoteInfo(quote),
            pw.SizedBox(height: 20),
            _buildSystemSpecs(quote),
            pw.SizedBox(height: 20),
            _buildItemizedList(quote),
            pw.SizedBox(height: 20),
            _buildTotalSection(quote),
            pw.SizedBox(height: 30),
            _buildFooter(companyProfile),
          ];
        },
      ),
    );
    
    // Save PDF to device
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/quote_${quote.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  /// Build PDF header with company information
  static pw.Widget _buildHeader(CompanyProfileModel? companyProfile) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              companyProfile?.companyName ?? 'Solar Company',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              companyProfile?.address ?? 'Company Address',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Phone: ${companyProfile?.phoneNumber ?? 'N/A'}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.Text(
          'SOLAR QUOTATION',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
      ],
    );
  }
  
  /// Build quote information section
  static pw.Widget _buildQuoteInfo(QuoteModel quote) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Project Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Project Name: ${quote.projectName}'),
                    pw.Text('Client Name: ${quote.clientName}'),
                    pw.Text('Location: ${quote.projectLocation}'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Quote ID: ${quote.id}'),
                    pw.Text('Date: ${quote.createdAt.toString().split(' ')[0]}'),
                    pw.Text('System Type: ${quote.isOffGrid ? 'Off-Grid/Hybrid' : 'Grid-Tied'}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build system specifications section
  static pw.Widget _buildSystemSpecs(QuoteModel quote) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'System Specifications',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('System Size: ${quote.systemSize.toStringAsFixed(2)} kW'),
              ),
              if (quote.isOffGrid)
                pw.Expanded(
                  child: pw.Text('Battery Size: ${quote.batterySize.toStringAsFixed(2)} kWh'),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build itemized list of components
  static pw.Widget _buildItemizedList(QuoteModel quote) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Itemized List',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            // Data rows
            ...quote.rows.map((row) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(row.description),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(row.quantity.toString()),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(row.unit),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('₱${row.estimatedPrice.toStringAsFixed(2)}'),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }
  
  /// Build total section
  static pw.Widget _buildTotalSection(QuoteModel quote) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              'Total Amount',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '₱${quote.totalPrice.toStringAsFixed(2)}',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build footer with additional information
  static pw.Widget _buildFooter(CompanyProfileModel? companyProfile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.Text(
          'Terms and Conditions:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          '• This quotation is valid for 30 days from the date of issue.',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '• Installation timeline: 2-4 weeks after contract signing.',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '• 25-year warranty on solar panels, 10-year warranty on inverters.',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 10),
        if (companyProfile?.footerNotes != null)
          pw.Text(
            companyProfile!.footerNotes!,
            style: const pw.TextStyle(fontSize: 10),
          ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Prepared by: ${companyProfile?.preparedBy ?? 'Solar Consultant'}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
