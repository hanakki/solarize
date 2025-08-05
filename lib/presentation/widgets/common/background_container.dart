import 'package:flutter/material.dart';

// provides the app's background image
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
          image: const AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover, // responsive resizing
          onError: (exception, stackTrace) {
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
