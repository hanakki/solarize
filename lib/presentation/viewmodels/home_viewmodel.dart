import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solarize/core/constants/strings.dart';

class HomeViewModel extends ChangeNotifier {
  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;
  String get formattedDate {
    final dayFormat = DateFormat('EEEE');
    final dateFormat = DateFormat('MMMM d');
    return '${dayFormat.format(_currentDate)} • ${dateFormat.format(_currentDate)}';
  }

  String get todayLabel => AppStrings.todayLabel;

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
          title: AppStrings.appSettingsTitle,
          description: AppStrings.appSettingsDescription,
          iconPath: 'assets/images/settings.png',
          route: '/settings',
        ),
      ];

  void navigateToFeature(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void refreshDate() {
    _currentDate = DateTime.now();
    notifyListeners();
  }
}

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
