class AppStrings {
  // App Information
  static const String appName = 'Solarize';
  static const String appTagline = 'Professional Solar Quotations Made Simple';

  // Home Screen
  static const String todayLabel = 'Today';
  static const String generateQuoteTitle = 'Generate Quote';
  static const String generateQuoteDescription =
      'Start a new estimate. Enter your details, apply presets, and export your solar plan to PDF.';
  static const String configurePresetsTitle = 'Configure Presets';
  static const String configurePresetsDescription =
      'Create and organize reusable presets to speed up your quotation process.';
  static const String advancedCalculatorTitle = 'Advanced Calculator';
  static const String advancedCalculatorDescription =
      'Enter advanced parameters to get precise solar generation estimates.';
  static const String appSettingsTitle = 'App Settings';
  static const String appSettingsDescription =
      'Adjust theme preferences, view app details, and contact our team.';

  // Quote Generation Steps
  static const String stepOneTitle = 'Calculate System Size';
  static const String stepOneDescription =
      'Let\'s start by estimating the ideal solar setup for your client.';
  static const String stepTwoTitle = 'Enter Project Details';
  static const String stepTwoDescription =
      'Enter project-specific details to help us customize your solar quotation.';
  static const String stepThreeTitle = 'Review Quotation & Send to Client';
  static const String stepThreeDescription =
      'Double-check the details, then send it directly to your client or save it for later.';

  // Form Labels
  static const String monthlyElectricBillLabel = 'MONTHLY ELECTRIC BILL (KWH)';
  static const String monthlyElectricBillPhpLabel =
      'MONTHLY ELECTRIC BILL (PHP)';
  static const String electricityProviderRateLabel =
      'ELECTRICTY PROVIDER RATE (₱/KWH)';
  static const String billOffsetPercentageLabel = 'BILL OFFSET PERCENTAGE';
  static const String billOffsetDescription =
      'The portion of your electric bill you want to cover with solar energy';
  static const String sunHoursLabel = 'SUN HOURS PER DAY';
  static const String sunHoursDescription =
      'Avg. sunlight hours per day (e.g., 5-6 hours on clear days, less on rainy days)';
  static const String systemSetupLabel = "SYSTEM SETUP";
  static const String offGridSetupLabel = 'Off-grid / Hybrid setup';
  static const String backupDurationLabel = 'BACKUP DURATION (HOURS)';
  static const String backupDurationDescription =
      'How long you want your battery to provide power during outages or at night';

  // Project Details
  static const String projectNameLabel = 'Project Name';
  static const String clientNameLabel = 'Client Name';
  static const String projectLocationLabel = 'Project Location';
  static const String quantityLabel = 'Quantity';
  static const String unitLabel = 'Unit';
  static const String descriptionLabel = 'Description';
  static const String estimatedPriceLabel = 'Estimated Price';

  // Buttons
  static const String calculateButton = 'CALCULATE';
  static const String proceedButton = 'PROCEED';
  static const String backButton = 'BACK';
  static const String saveButton = 'SAVE';
  static const String addRowButton = 'ADD ROW';
  static const String loadPresetButton = 'LOAD PRESET';
  static const String shareWithClientButton = 'SHARE WITH CLIENT';
  static const String exportAsPngButton = 'EXPORT AS PNG';
  static const String backToHomeButton = 'BACK TO HOME';

  // About Section
  static const String aboutAppTitle = 'About the App';
  static const String aboutAppDescription =
      'Solarize is a simple yet powerful app built for solar consultants to quickly create professional quotations using customizable input presets. Whether you\'re selecting price values, dropdowns, or checkboxes, the app helps you generate clear estimates and export them as PDFs or images you can easily share via email or messaging apps.';

  static const String aboutUsTitle = 'About Us';
  static const String aboutUsDescription =
      'This app was built by Hanakki, a solo developer and 3rd year Computer Engineering student from Toledo City, Cebu, studying at the University of San Carlos (USC). Originally created as a final project for CPE 3323 Mobile Applications Development, this app also serves as a small tribute to her father, who runs a solar company and inspired the idea behind making quotation estimates simpler and more efficient. Got issues or suggestions? Hit her up at solarize@gmail.com.';

  // Error Messages
  static const String requiredFieldError = 'This field is required';
  static const String invalidEmailError = 'Please enter a valid email address';
  static const String invalidNumberError = 'Please enter a valid number';
  static const String calculationError = 'Error occurred during calculation';
  static const String saveError = 'Error saving data';
  static const String loadError = 'Error loading data';
}
