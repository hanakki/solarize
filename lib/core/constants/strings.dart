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
  static const String electricBillPhpToggle =
      'Enter monthly electric bill in PHP (₱)';
  static const String billOffsetPercentageLabel = 'BILL OFFSET PERCENTAGE';
  static const String billOffsetDescription =
      'The portion of your electric bill you want to cover with solar energy';
  static const String sunHoursLabel = 'SUN HOURS PER DAY';
  static const String sunHoursDescription =
      'Avg. sunlight hours per day (e.g., 5-6 hours on clear days, less on rainy days)';
  static const String systemSetupLabel = "SYSTEM SETUP";
  static const String offGridSetupLabel = 'Off-grid / Hybrid Setup';
  static const String backupDurationLabel = 'BACKUP DURATION (HOURS)';
  static const String backupDurationDescription =
      'How long you want your battery to provide power during outages or at night';
  static const String presetTitleLabel = "PRESET TITLE";
  static const String addParticularLabel = "PARTICULAR";
  static const String addQuantityLabel = "QUANTITY";
  static const String addUnitLabel = "UNIT";
  static const String addDescriptionLabel = "DESCRIPTION";
  static const String addEstimatedPriceLabel = "ESTIMATED PRICE";
  static const String addTotalPriceLabel = "TOTAL PRICE";
  static const String companyLogoLabel = "COMPANY LOGO";
  static const String companyNameLabel = "COMPANY NAME";
  static const String companyAddressLabel = "ADDRESS";
  static const String comapnyMobileLabel = "MOBILE NUMBER";
  static const String companyPhoneLabel = "TELEPHONE NUMBER";
  static const String companyEmailLabel = "EMAIL ADDRESS";
  static const String companyWebsiteLabel = "WEBSITE";
  static const String footerNotesLabel = "FOOTER NOTES";
  static const String preparedByLabel = "PREPARED BY";

  // API Integration
  static const String apiIntegrationLabel = 'ENABLE API SUPPORT';
  static const String apiIntegrationToggle =
      'Use PVWatts for more accurate calculations';
  static const String apiIntegrationDescription =
      'Enable API integration for location-based solar calculations';
  static const String apiIntegrationCheckboxLabel = 'Enable PVWatts API';
  static const String apiEnabledDescription =
      'Using real solar data for precise calculations';
  static const String apiDisabledDescription =
      'Using estimated calculations (less accurate)';

  // Solar Panel Configuration
  static const String solarPanelSizeLabel = 'PANEL SIZE (KW)';
  static const String solarPanelSizeHint = 'e.g., 1.0';
  static const String solarPanelPriceLabel = 'PANEL PRICE (₱)';
  static const String solarPanelPriceHint = 'e.g., 40000';
  static const String solarPanelConfigurationTitle =
      'SOLAR PANEL CONFIGURATION';
  static const String solarPanelConfigurationDescription =
      'Configure your solar panel specifications';

  // Battery Configuration
  static const String batterySizeLabel = 'BATTERY SIZE (KWH)';
  static const String batterySizeHint = 'e.g., 5.0';
  static const String batteryPriceLabel = 'BATTERY PRICE (₱)';
  static const String batteryPriceHint = 'e.g., 125000';
  static const String batteryConfigurationTitle = 'Battery Configuration';
  static const String batteryConfigurationDescription =
      'Configure your battery specifications for off-grid/hybrid systems';

  // Location Configuration
  static const String latitudeLabel = 'LATITUDE';
  static const String latitudeHint = 'e.g., 10.387';
  static const String longitudeLabel = 'LONGITUDE';
  static const String longitudeHint = 'e.g., 123.6502';
  static const String locationConfigurationTitle = 'LOCATION CONFIGURATION';
  static const String locationConfigurationDescription =
      'Enter your location coordinates for accurate solar calculations';

  // Calculation Results
  static const String calculationSetup = 'Setup';
  static const String calculationSystemSize = 'System Size';
  static const String calculationNumberOfPanels = 'Number of Panels';
  static const String calculationTotalPanelCost = 'Total Panel Cost';
  static const String calculationBatterySize = 'Battery Size';
  static const String calculationNumberOfBatteries = 'Number of Batteries';
  static const String calculationTotalBatteryCost = 'Total Battery Cost';
  static const String calculationOverallSystemCost = 'Overall System Cost';
  static const String calculationAnnualProduction = 'Annual Production';
  static const String calculationMonthlyProduction = 'Monthly Production';
  static const String calculationOffGrid = 'Off-Grid / Hybrid';
  static const String calculationGridTie = 'Grid-Tied';

  // Project Details
  static const String projectNameLabel = 'PROJECT NAME';
  static const String clientNameLabel = 'CLIENT NAME';
  static const String projectLocationLabel = 'PROJECT LOCATION';
  static const String quantityLabel = 'QUANTITY';
  static const String unitLabel = 'UNIT';
  static const String descriptionLabel = 'DESCRIPTION';
  static const String estimatedPriceLabel = 'ESTIMATED PRICE';

  // Buttons
  static const String calculateButton = 'CALCULATE';
  static const String proceedButton = 'PROCEED';
  static const String backButton = 'BACK';
  static const String saveButton = 'SAVE';
  static const String addRowButton = 'ADD ROW';
  static const String loadPresetButton = 'LOAD PRESET';
  static const String shareWithClientButton = 'SHARE WITH CLIENT';
  static const String exportAsPngButton = 'SAVE PDF';
  static const String backToHomeButton = 'BACK TO HOME';
  static const String saveCompanyProfileButton = 'SAVE COMPANY PROFILE';

  // About Section
  static const String aboutAppTitle = 'About the App';
  static const String aboutAppDescription =
      'Solarize is a simple yet powerful app built for solar consultants to quickly create professional quotations using customizable input presets. Whether you\'re selecting price values, dropdowns, or checkboxes, the app helps you generate clear estimates and export them as PDFs or images you can easily share via email or messaging apps.';

  static const String aboutUsTitle = 'About Us';
  static const String aboutUsDescription =
      'This app was built by Hanakki, a solo developer and 3rd year Computer Engineering student from Toledo City, Cebu, studying at the University of San Carlos (USC). \n\nOriginally created as a final project for CPE 3323 Mobile Applications Development, this app also serves as a small tribute to her father, who runs a solar company and inspired the idea behind making quotation estimates simpler and more efficient. \n\nGot issues or suggestions? Hit her up at solarize@gmail.com.';

  // Error Messages
  static const String requiredFieldError = 'This field is required';
  static const String invalidEmailError = 'Please enter a valid email address';
  static const String invalidNumberError = 'Please enter a valid number';
  static const String calculationError = 'Error occurred during calculation';
  static const String saveError = 'Error saving data';
  static const String loadError = 'Error loading data';
}
