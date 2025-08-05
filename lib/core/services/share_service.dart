import 'dart:io';
import 'package:share_plus/share_plus.dart';

// for sharing files and content
class ShareService {
  static Future<bool> sharePdf(File pdfFile, String subject) async {
    try {
      if (!await pdfFile.exists()) {
        throw Exception('PDF file does not exist');
      }

      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: subject,
        text: 'Please find attached your solar quotation.',
      );
      return true;
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }
}
