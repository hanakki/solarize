import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solarize/core/constants/strings.dart';

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
  String get todayLabel => AppStrings.todayLabel;

  /// Feature card data
  List<FeatureCardData> get featureCards => [
        const FeatureCardData(
          title: AppStrings.generateQuoteTitle,
          description: AppStrings.generateQuoteDescription,
          iconPath: 'assets/images/genquote.png',
          route: '/quote-generation',
        ),
        const FeatureCardData(
          title: AppStrings.configurePresetsTitle,
          description: AppStrings.configurePresetsDescription,
          iconPath: 'assets/images/preset.png',
          route: '/presets',
        ),
        const FeatureCardData(
          title: AppStrings.advancedCalculatorTitle,
          description: AppStrings.advancedCalculatorDescription,
          iconPath: 'assets/images/advanced_calculator_icon.png',
          route: '/advanced-calculator',
        ),
        const FeatureCardData(
          title: AppStrings.appSettingsTitle,
          description: AppStrings.appSettingsDescription,
          iconPath: 'assets/images/settings.png',
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
