class AppConstants {
  // App Information
  static const String appName = 'Solarize';
  static const String appVersion = '1.0.0';

  // Calculation Constants
  static const double powerFactor = 0.8;
  static const double depthOfDischarge = 0.8;
  static const double batteryEfficiency = 0.9;
  static const int daysInMonth = 30;

  // Dummy Prices (Philippine Peso)
  static const double solarPanelPricePerWatt = 45.0; // ₱45 per watt
  static const double batteryPricePerKwh = 25000.0; // ₱25,000 per kWh

  // UI Constants
  static const double cardImageRatio = 0.5;
  static const double borderRadiusBig = 24.0;
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 16.0;
  static const double defaultPadding = 16.0;

  // Storage Keys
  static const String quotesStorageKey = 'saved_quotes';
  static const String presetsStorageKey = 'saved_presets';
  static const String settingsStorageKey = 'app_settings';

  // File Extensions
  static const String pdfExtension = '.pdf';
  static const String pngExtension = '.png';
}
