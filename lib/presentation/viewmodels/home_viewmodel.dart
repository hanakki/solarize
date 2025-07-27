import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ViewModel for the home screen
/// Manages home screen state and navigation logic
class HomeViewModel extends ChangeNotifier {
  // Current date information
  DateTime _currentDate = DateTime.now();

  // Getters
  DateTime get currentDate => _currentDate;

  /// Get formatted date string (e.g., "Monday • July 7")
  String get formattedDate {
    final dayFormat = DateFormat('EEEE');
    final dateFormat = DateFormat('MMMM d');
    return '${dayFormat.format(_currentDate)} • ${dateFormat.format(_currentDate)}';
  }

  /// Get today label
  String get todayLabel => 'Today';

  /// Feature card data
  List<FeatureCardData> get featureCards => [
        const FeatureCardData(
          title: 'Generate Quote',
          description:
              'Start a new estimate. Enter your details, apply presets, and export your solar plan to PDF.',
          iconPath: 'assets/images/generate_quote_icon.png',
          route: '/quote-generation',
        ),
        const FeatureCardData(
          title: 'Configure Presets',
          description:
              'Create and organize reusable presets to speed up your quotation process.',
          iconPath: 'assets/images/configure_presets_icon.png',
          route: '/presets',
        ),
        const FeatureCardData(
          title: 'Advanced Calculator',
          description:
              'Enter advanced parameters to get precise solar generation estimates.',
          iconPath: 'assets/images/advanced_calculator_icon.png',
          route: '/advanced-calculator',
        ),
        const FeatureCardData(
          title: 'App Settings',
          description:
              'Adjust theme preferences, view app details, and contact our team.',
          iconPath: 'assets/images/app_settings_icon.png',
          route: '/settings',
        ),
      ];

  /// Navigate to feature
  void navigateToFeature(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  /// Refresh current date (useful for testing or if app stays open overnight)
  void refreshDate() {
    _currentDate = DateTime.now();
    notifyListeners();
  }
}

/// Data class for feature cards
class FeatureCardData {
  final String title;
  final String description;
  final String iconPath;
  final String route;

  const FeatureCardData({
    required this.title,
    required this.description,
    required this.iconPath,
    required this.route,
  });
}
