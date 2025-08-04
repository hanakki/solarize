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
  /// Test method to verify logo loading (for debugging)
  static Future<void> testLogoLoading(String logoPath) async {
    try {
      print('=== LOGO LOADING TEST ===');
      print('Testing logo path: $logoPath');

      final file = File(logoPath);
      if (!await file.exists()) {
        print('❌ Logo file does not exist');
        return;
      }

      final fileSize = await file.length();
      print('✅ Logo file exists, size: $fileSize bytes');

      final bytes = await file.readAsBytes();
      print('✅ Logo bytes read: ${bytes.length} bytes');

      final preparedBytes = await _prepareImageForPdf(bytes);
      if (preparedBytes != null) {
        print('✅ Logo prepared successfully for PDF');
        print('✅ Logo format detected and validated');
      } else {
        print('❌ Logo preparation failed');
      }

      print('=== END LOGO TEST ===');
    } catch (e) {
      print('❌ Logo test failed: $e');
    }
  }

  /// Get user-friendly file path for display
  static String getUserFriendlyPath(String filePath) {
    // Extract just the filename and folder for display
    final pathParts = filePath.split('/');
    if (pathParts.length >= 2) {
      final folder = pathParts[pathParts.length - 2];
      final fileName = pathParts.last;
      return '$folder/$fileName';
    }
    return filePath;
  }

  /// Validate and prepare image for PDF
  static Future<Uint8List?> _prepareImageForPdf(Uint8List imageBytes) async {
    try {
      // Check if the image bytes start with common image format headers
      if (imageBytes.length < 4) {
        print('Image bytes too short');
        return null;
      }

      // Check for JPEG header
      if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
        print('Detected JPEG format');
        return imageBytes;
      }

      // Check for PNG header
      if (imageBytes[0] == 0x89 &&
          imageBytes[1] == 0x50 &&
          imageBytes[2] == 0x4E &&
          imageBytes[3] == 0x47) {
        print('Detected PNG format');
        return imageBytes;
      }

      print('Unknown image format, attempting to use anyway');
      return imageBytes;
    } catch (e) {
      print('Error preparing image for PDF: $e');
      return null;
    }
  }

  /// Generate a PDF quotation document
  static Future<File> generateQuotePdf(
    QuoteModel quote,
    CompanyProfileModel? companyProfile,
  ) async {
    final pdf = pw.Document();

    // Load logo image if available
    pw.MemoryImage? logoImage;
    if (companyProfile?.hasLogo == true && companyProfile!.logoPath != null) {
      try {
        print('Attempting to load logo from: ${companyProfile.logoPath}');

        // Test logo loading first
        await testLogoLoading(companyProfile.logoPath!);

        final logoBytes = await _loadLogoImage(companyProfile.logoPath!);
        final preparedBytes = await _prepareImageForPdf(logoBytes);

        if (preparedBytes != null) {
          logoImage = pw.MemoryImage(preparedBytes);
          print(
              'Logo loaded successfully, size: ${preparedBytes.length} bytes');
        } else {
          print('Failed to prepare logo for PDF');
        }
      } catch (e) {
        // Logo loading failed, continue without logo
        print('Failed to load logo: $e');
      }
    } else {
      print(
          'No logo available - hasLogo: ${companyProfile?.hasLogo}, logoPath: ${companyProfile?.logoPath}');
    }

    // Add pages to PDF
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
            pw.SizedBox(height: 20),
            _buildTotalSection(quote),
            pw.SizedBox(height: 30),
            _buildFooter(companyProfile),
          ];
        },
      ),
    );

    // Save PDF to downloads folder for better accessibility
    final downloadsDir = await _getDownloadsDirectory();
    final fileName =
        'Solar_Quote_${quote.projectName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${downloadsDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Get downloads directory
  static Future<Directory> _getDownloadsDirectory() async {
    try {
      // Try to get external storage directory (downloads)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Try different possible download folder paths
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
    } catch (e) {
      print('Failed to access external storage: $e');
    }

    // Fallback to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/Downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir;
  }

  /// Build PDF header with company information and logo
  static pw.Widget _buildHeader(
      CompanyProfileModel? companyProfile, pw.MemoryImage? logoImage) {
    print('Building header - logoImage is null: ${logoImage == null}');
    if (logoImage != null) {
      print('Logo image will be displayed in PDF');
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo if available
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
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'SOLAR QUOTATION',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Professional Solar Solutions',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Load logo image from file path
  static Future<Uint8List> _loadLogoImage(String logoPath) async {
    try {
      print('Loading logo from path: $logoPath');
      final file = File(logoPath);

      if (!await file.exists()) {
        print('Logo file does not exist at path: $logoPath');
        throw Exception('Logo file does not exist');
      }

      final fileSize = await file.length();
      print('Logo file size: $fileSize bytes');

      if (fileSize == 0) {
        print('Logo file is empty');
        throw Exception('Logo file is empty');
      }

      final bytes = await file.readAsBytes();
      print('Successfully read logo bytes: ${bytes.length} bytes');

      return bytes;
    } catch (e) {
      print('Error loading logo: $e');
      throw Exception('Failed to load logo: $e');
    }
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
                    pw.Text(
                        'Date: ${quote.createdAt.toString().split(' ')[0]}'),
                    pw.Text(
                        'System Type: ${quote.isOffGrid ? 'Off-Grid/Hybrid' : 'Grid-Tied'}'),
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
                  child: pw.Text('Price',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                      child:
                          pw.Text('₱${row.estimatedPrice.toStringAsFixed(2)}'),
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
