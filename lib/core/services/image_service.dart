import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/quote_model.dart';

/// Service class for generating PNG images from widgets
/// Converts quotation data into shareable image format
class ImageService {
  /// Copy logo file to app's permanent directory
  /// Returns the new path where the logo is stored
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

  /// Check if logo file exists at the given path
  static Future<bool> logoExists(String? logoPath) async {
    if (logoPath == null || logoPath.isEmpty) return false;

    try {
      final file = File(logoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete logo file from storage
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

  // /// Generate a PNG image from a quotation
  // static Future<File> generateQuoteImage(
  //   QuoteModel quote,
  //   GlobalKey repaintBoundaryKey,
  // ) async {
  //   try {
  //     // Capture the widget as an image
  //     RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
  //         .findRenderObject() as RenderRepaintBoundary;

  //     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData? byteData =
  //         await image.toByteData(format: ui.ImageByteFormat.png);
  //     Uint8List pngBytes = byteData!.buffer.asUint8List();

  //     // Save to device
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/quote_${quote.id}.png');
  //     await file.writeAsBytes(pngBytes);

  //     return file;
  //   } catch (e) {
  //     throw Exception('Failed to generate image: $e');
  //   }
  // }

  // /// Create a widget representation of the quote for image generation
  // static Widget buildQuoteImageWidget(QuoteModel quote) {
  //   return Container(
  //     width: 800,
  //     padding: const EdgeInsets.all(32),
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         // Header
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text(
  //               'SOLAR QUOTATION',
  //               style: TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.blue,
  //               ),
  //             ),
  //             Text(
  //               'Quote #${quote.id.substring(0, 8)}',
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),

  //         // Project Information
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.blue.shade50,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Project: ${quote.projectName}',
  //                 style: const TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text('Client: ${quote.clientName}'),
  //               Text('Location: ${quote.projectLocation}'),
  //               Text('System Size: ${quote.systemSize.toStringAsFixed(2)} kW'),
  //               if (quote.isOffGrid)
  //                 Text(
  //                     'Battery Size: ${quote.batterySize.toStringAsFixed(2)} kWh'),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 20),

  //         // Total Amount
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.blue,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Text(
  //                 'Total Amount:',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               Text(
  //                 '₱${quote.totalPrice.toStringAsFixed(2)}',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 20),

  //         // Footer
  //         const Text(
  //           'Generated by Solarize App',
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.grey,
  //           ),
  //         ),
  // ],
  // ),
  // );
  // }
}
