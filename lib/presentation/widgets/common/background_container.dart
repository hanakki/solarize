import 'package:flutter/material.dart';

/// Container widget that provides the app's background image
/// Handles responsive resizing and ensures background covers entire screen
class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final String? backgroundImagePath;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.backgroundImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          // Use placeholder background for now
          // TODO: Replace with actual background image asset
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover, // Ensures responsive resizing
          onError: (exception, stackTrace) {
            // Fallback to gradient background if image fails to load
            debugPrint('Background image failed to load: $exception');
          },
        ),
        // Fallback gradient background
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F7FA),
            Color(0xFFC3CFE2),
          ],
        ),
      ),
      child: child,
    );
  }
}
