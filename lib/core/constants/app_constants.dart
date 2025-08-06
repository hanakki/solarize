class AppConstants {
  static const double systemEfficiency = 0.8;
  static const double depthOfDischarge = 0.8;
  static const double batteryEfficiency = 0.9;
  static const double powerFactor = 0.9;
  static const int daysInMonth = 30;

  static const double pvwattsSystemCapacity = 1.0;
  static const double pvwattsTilt = 10.0;
  static const double pvwattsAzimuth = 180.0;
  static const int pvwattsModuleType = 0;
  static const int pvwattsArrayType = 1;
  static const double pvwattsLosses = 16.0;
  static const String pvwattsTimeframe = 'monthly';

  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 16.0;
  static const double defaultPadding = 16.0;
  static const double defaultPaddingBig = 24.0;

  static const String quotesStorageKey = 'saved_quotes';
  static const String presetsStorageKey = 'saved_presets';
  static const String settingsStorageKey = 'app_settings';
}
