class AppConstants {
  // App Information
  static const String appName = 'Solarize';
  static const String appVersion = '1.0.0';

  // Calculation Constants
  static const double systemEfficiency = 0.8;
  static const double depthOfDischarge = 0.8;
  static const double batteryEfficiency = 0.9;
  static const double powerFactor = 0.9;
  static const int daysInMonth = 30;

  // PVWatts API Constants
  static const double pvwattsSystemCapacity = 1.0;
  static const double pvwattsTilt = 10.0;
  static const double pvwattsAzimuth = 180.0;
  static const int pvwattsModuleType = 0;
  static const int pvwattsArrayType = 1;
  static const double pvwattsLosses = 16.0;
  static const String pvwattsTimeframe = 'monthly';

  // Default Location (Toledo City, Philippines)
  static const double defaultLatitude = 10.387;
  static const double defaultLongitude = 123.6502;

  // Dummy Prices (Philippine Peso)
  static const double batteryPricePerKwh = 25000.0;

  // UI Constants
  static const double cardImageRatio = 0.5;
  static const double borderRadiusBig = 24.0;
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 16.0;
  static const double defaultPadding = 16.0;
  static const double defaultPaddingBig = 24.0;

  // Storage Keys
  static const String quotesStorageKey = 'saved_quotes';
  static const String presetsStorageKey = 'saved_presets';
  static const String settingsStorageKey = 'app_settings';

  // File Extensions
  static const String pdfExtension = '.pdf';
}
