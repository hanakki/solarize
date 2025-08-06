import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/company_profile_model.dart';

// for generating PDF documents
class PdfService {
  // user-friendly file path for display (for snackbar)
  // only the filename and folder for display
  static String getUserFriendlyPath(String filePath) {
    final pathParts = filePath.split('/');
    if (pathParts.length >= 2) {
      final folder = pathParts[pathParts.length - 2];
      final fileName = pathParts.last;
      return '$folder/$fileName';
    }
    return filePath;
  }

  static Future<Uint8List?> _prepareImageForPdf(Uint8List imageBytes) async {
    try {
      if (imageBytes.length < 4) {
        return null;
      }

      if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
        return imageBytes;
      }

      if (imageBytes[0] == 0x89 &&
          imageBytes[1] == 0x50 &&
          imageBytes[2] == 0x4E &&
          imageBytes[3] == 0x47) {
        return imageBytes;
      }

      return imageBytes;
    } catch (e) {
      return null;
    }
  }

  // Generate a PDF
  static Future<File> generateQuotePdf(
    QuoteModel quote,
    CompanyProfileModel? companyProfile,
  ) async {
    final pdf = pw.Document();

    // Load logo image if available
    pw.MemoryImage? logoImage;
    if (companyProfile?.hasLogo == true && companyProfile!.logoPath != null) {
      final logoBytes = await _loadLogoImage(companyProfile.logoPath!);
      final preparedBytes = await _prepareImageForPdf(logoBytes);

      if (preparedBytes != null) {
        logoImage = pw.MemoryImage(preparedBytes);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(companyProfile, logoImage),
            pw.SizedBox(height: 20),
            _buildQuoteInfo(quote),
            pw.SizedBox(height: 20),
            _buildSystemSpecs(quote),
            pw.SizedBox(height: 20),
            _buildItemizedList(quote),
            pw.SizedBox(height: 30),
            _buildFooter(companyProfile),
          ];
        },
      ),
    );

    // Save to downloads folder
    final downloadsDir = await _getDownloadsDirectory();
    final fileName =
        'Solar_Quote_${quote.projectName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${downloadsDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Get downloads directory
  static Future<Directory> _getDownloadsDirectory() async {
    final externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      final possiblePaths = [
        '${externalDir.path}/Download',
        '${externalDir.path}/Downloads',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
      ];

      for (final path in possiblePaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          return dir;
        }
      }

      // Create Download folder in external storage
      final downloadsDir = Directory('${externalDir.path}/Download');
      await downloadsDir.create(recursive: true);
      return downloadsDir;
    }

    // Fallback to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/Downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir;
  }

  static pw.Widget _buildHeader(
      CompanyProfileModel? companyProfile, pw.MemoryImage? logoImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null) ...[
                pw.Image(
                  logoImage,
                  width: 80,
                  height: 40,
                  fit: pw.BoxFit.contain,
                ),
                pw.SizedBox(height: 5),
              ],
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
              if (companyProfile?.email != null)
                pw.Text(
                  'Email: ${companyProfile!.email}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // get logo image from file path
  static Future<Uint8List> _loadLogoImage(String logoPath) async {
    try {
      final file = File(logoPath);
      if (!await file.exists()) {
        throw Exception('Logo file does not exist');
      }
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Logo file is empty');
      }
      final bytes = await file.readAsBytes();
      return bytes;
    } catch (e) {
      throw Exception('Failed to load logo: $e');
    }
  }

  // quote information section
  static pw.Widget _buildQuoteInfo(QuoteModel quote) {
    return pw.Column(
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
                  pw.Text(
                      'System Type: ${quote.isOffGrid ? 'Off-Grid/Hybrid' : 'Grid-Tied'}'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // system specs section
  static pw.Widget _buildSystemSpecs(QuoteModel quote) {
    return pw.Column(
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
              child: pw.Text(
                  'System Size: ${quote.systemSize.toStringAsFixed(2)} kW'),
            ),
            if (quote.isOffGrid)
              pw.Expanded(
                child: pw.Text(
                    'Battery Size: ${quote.batterySize.toStringAsFixed(2)} kWh'),
              ),
          ],
        ),
      ],
    );
  }

  // itemized list
  static pw.Widget _buildItemizedList(QuoteModel quote) {
    // Calculate total from rows
    final totalFromRows = quote.rows.fold<double>(
        0.0, (sum, row) => sum + (row.quantity * row.estimatedPrice));

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
          columnWidths: const {
            0: pw.FlexColumnWidth(2), // Description
            1: pw.FlexColumnWidth(0.5), // Qty
            2: pw.FlexColumnWidth(0.8), // Unit
            3: pw.FlexColumnWidth(1.2), // Unit Price
            4: pw.FlexColumnWidth(1.2), // Subtotal
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Description',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Qty',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Unit',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Unit Price',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Subtotal',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            // Data row
            ...quote.rows.map((row) {
              final subtotal = row.quantity * row.estimatedPrice;
              return pw.TableRow(
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
                    child: pw.Text('P${row.estimatedPrice.toStringAsFixed(2)}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('P${subtotal.toStringAsFixed(2)}'),
                  ),
                ],
              );
            }),
            // Subtotal row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey50),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(''),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(''),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(''),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Subtotal:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('P${totalFromRows.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // footer with additional information
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
          '- This quotation is for estimation purposes only and does not constitute a formal offer or agreement.',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '- It should not be treated as an official or legally binding document.',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '- Figures provided herein are indicative and subject to change upon detailed site inspection and finalized agreement.',
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
