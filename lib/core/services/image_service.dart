import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageService {
  // for copying logo file to app's permanent directory
  // Returns the new path where the logo is stored
  static Future<String> copyLogoToAppDirectory(String originalPath) async {
    try {
      final originalFile = File(originalPath);

      if (!await originalFile.exists()) {
        throw Exception('Original logo file does not exist');
      }

      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final logosDir = Directory('${appDir.path}/logos');

      // Create logos directory if it doesn't exist
      if (!await logosDir.exists()) {
        await logosDir.create(recursive: true);
      }

      // Generate unique filename
      final fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = '${logosDir.path}/$fileName';

      // Copy file to app directory
      await originalFile.copy(newPath);

      return newPath;
    } catch (e) {
      throw Exception('Failed to copy logo: $e');
    }
  }

  // Check here if logo file exists at  path
  static Future<bool> logoExists(String? logoPath) async {
    if (logoPath == null || logoPath.isEmpty) return false;

    try {
      final file = File(logoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // for deleting logo file from storage
  static Future<bool> deleteLogo(String? logoPath) async {
    if (logoPath == null || logoPath.isEmpty) return true;

    try {
      final file = File(logoPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return true; // File doesn't exist, consider it deleted
    } catch (e) {
      return false;
    }
  }
}
