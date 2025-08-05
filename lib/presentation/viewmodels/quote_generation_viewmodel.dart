import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../data/models/quote_model.dart';
import '../../data/models/calculation_result_model.dart';
import '../../data/models/project_details_model.dart';
import '../../data/models/project_row_model.dart';
import '../../data/repositories/quote_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/utils/calculations.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/share_service.dart';

/// ViewModel for the quote generation flow
/// Manages the 3-step quote creation process and calculations
class QuoteGenerationViewModel extends ChangeNotifier {
  final QuoteRepository _quoteRepository;
  final SettingsRepository _settingsRepository;
  final Uuid _uuid = const Uuid();

  QuoteGenerationViewModel(this._quoteRepository, this._settingsRepository);

  // Current step (1, 2, or 3)
  int _currentStep = 1;

  // Loading states
  bool _isCalculating = false;
  bool _isSaving = false;
  bool _isGeneratingPdf = false;
  bool _isGeneratingImage = false;

  // Step 1: Calculation inputs
  double _monthlyBillKwh = 0;
  double _monthlyBillValue = 0; // The actual value entered (PHP or kWh)
  double _billOffsetPercentage = 80;
  double _sunHoursPerDay = 4.5;
  bool _isOffGrid = false;
  double _backupHours = 8;
  bool _usedPhpBilling = false;
  double _electricityRate = 12.0; // Default PHP rate per kWh
  bool _useApiIntegration = true; // Enable API integration by default

  // Solar Panel Configuration
  double _solarPanelSizeKw = 1.0; // Default 1kW panel
  double _solarPanelPricePhp = 40000.0; // Default ₱40,000 per panel

  // Battery Configuration (for off-grid/hybrid)
  double _batterySizeKwh = 5.0; // Default 5kWh battery
  double _batteryPricePhp = 125000.0; // Default ₱125,000 per battery

  // Location for PVWatts API (Toledo City, Philippines default)
  double _latitude = 10.387; // Toledo City coordinates
  double _longitude = 123.6502;

  // Calculation results
  CalculationResultModel? _calculationResult;

  // Step 2: Project details
  ProjectDetailsModel? _projectDetails;

  // Current quote being created
  QuoteModel? _currentQuote;

  // Generated files
  File? _generatedPdfFile;
  File? _generatedImageFile;

  // Error handling
  String? _errorMessage;

  // State variables for tracking changes
  bool _dataChanged = false;

  // Getters
  int get currentStep => _currentStep;
  bool get isCalculating => _isCalculating;
  bool get isSaving => _isSaving;
  bool get isGeneratingPdf => _isGeneratingPdf;
  bool get isGeneratingImage => _isGeneratingImage;
  double get monthlyBillKwh => _monthlyBillKwh;
  double get monthlyBillValue => _monthlyBillValue;
  double get billOffsetPercentage => _billOffsetPercentage;
  double get sunHoursPerDay => _sunHoursPerDay;
  bool get isOffGrid => _isOffGrid;
  double get backupHours => _backupHours;
  bool get usedPhpBilling => _usedPhpBilling;
  double get electricityRate => _electricityRate;
  bool get useApiIntegration => _useApiIntegration;
  double get latitude => _latitude;
  double get longitude => _longitude;

  // Solar Panel Configuration Getters
  double get solarPanelSizeKw => _solarPanelSizeKw;
  double get solarPanelPricePhp => _solarPanelPricePhp;

  // Battery Configuration Getters
  double get batterySizeKwh => _batterySizeKwh;
  double get batteryPricePhp => _batteryPricePhp;

  CalculationResultModel? get calculationResult => _calculationResult;
  ProjectDetailsModel? get projectDetails => _projectDetails;
  QuoteModel? get currentQuote => _currentQuote;
  File? get generatedPdfFile => _generatedPdfFile;
  File? get generatedImageFile => _generatedImageFile;
  String? get errorMessage => _errorMessage;
  bool get dataChanged => _dataChanged;

  /// Get step information
  StepInfo getStepInfo(int step) {
    switch (step) {
      case 1:
        return const StepInfo(
          title: 'Step 1: Calculate System Size',
          description:
              'Let\'s start by estimating the ideal solar setup for your client.',
        );
      case 2:
        return const StepInfo(
          title: 'Step 2: Enter Project Details',
          description:
              'Enter project-specific details to help us customize your solar quotation.',
        );
      case 3:
        return const StepInfo(
          title: 'Step 3: Review Quotation & Send to Client',
          description:
              'Double-check the details, then send it directly to your client or save it for later.',
        );
      default:
        return const StepInfo(title: '', description: '');
    }
  }

  /// Get progress state for each step
  ProgressState getProgressState(int step) {
    if (step < _currentStep) return ProgressState.completed;
    if (step == _currentStep) return ProgressState.active;
    return ProgressState.inactive;
  }

  /// Mark data as changed (will trigger PDF regeneration)
  void _markDataChanged() {
    _dataChanged = true;
  }

  /// Clear data changed flag
  void _clearDataChanged() {
    _dataChanged = false;
  }

  // Step 1 Methods

  /// Update monthly bill in kWh
  void updateMonthlyBillKwh(double value) {
    _monthlyBillKwh = value;
    _monthlyBillValue = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update monthly bill in PHP (stores the PHP value)
  void updateMonthlyBillPhp(double value) {
    _monthlyBillValue = value;
    // Don't convert here, let the calculation functions handle it
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update bill offset percentage
  void updateBillOffsetPercentage(double value) {
    _billOffsetPercentage = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update sun hours per day
  void updateSunHoursPerDay(double value) {
    _sunHoursPerDay = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Toggle off-grid setup
  void toggleOffGrid(bool value) {
    _isOffGrid = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update backup hours
  void updateBackupHours(double value) {
    _backupHours = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Toggle PHP billing mode
  void togglePhpBilling(bool value) {
    _usedPhpBilling = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Toggle API integration
  void toggleApiIntegration(bool value) {
    _useApiIntegration = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update electricity rate
  void updateElectricityRate(double value) {
    _electricityRate = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update solar panel size
  void updateSolarPanelSize(double value) {
    _solarPanelSizeKw = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update solar panel price
  void updateSolarPanelPrice(double value) {
    _solarPanelPricePhp = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update battery size
  void updateBatterySize(double value) {
    _batterySizeKwh = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update battery price
  void updateBatteryPrice(double value) {
    _batteryPricePhp = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Update location coordinates
  void updateLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Calculate system size and generate results
  Future<void> calculateSystem() async {
    // Check if we have the minimum required inputs
    if (_monthlyBillKwh <= 0 || _billOffsetPercentage <= 0) {
      _setError('Please provide valid monthly bill and bill offset percentage');
      return;
    }

    try {
      _isCalculating = true;
      _clearError();
      notifyListeners();

      print('=== CALCULATION START ===');
      print('Monthly Bill (kWh): $_monthlyBillKwh');
      print('Electricity Rate: $_electricityRate');
      print('Bill Offset: $_billOffsetPercentage%');
      print('Sun Hours: $_sunHoursPerDay');
      print('Backup Hours: $_backupHours');
      print('API Integration: $_useApiIntegration');
      print('Solar Panel Size: $_solarPanelSizeKw kW');
      print('Solar Panel Price: ₱$_solarPanelPricePhp');
      print('Battery Size: $_batterySizeKwh kWh');
      print('Battery Price: ₱$_batteryPricePhp');
      print('Latitude: $_latitude');
      print('Longitude: $_longitude');

      double systemSizeKw;
      double? pvwattsAnnualOutput;
      double? pvwattsDailyOutput;

      if (_useApiIntegration) {
        print('=== USING PVWATTS API ===');

        // Calculate target daily consumption with conversion
        final targetDailyConsumption =
            SolarCalculations.calculateTargetDailyConsumptionWithConversion(
          monthlyBillValue: _monthlyBillValue,
          billOffsetPercentage: _billOffsetPercentage,
          isPhpBilling: _usedPhpBilling,
          electricityRate: _electricityRate,
        );
        print('Target Daily Consumption: $targetDailyConsumption kWh');

        // Get PVWatts data
        final pvwattsResponse = await SolarCalculations.getPvwattsAnnualOutput(
          latitude: _latitude,
          longitude: _longitude,
        );
        pvwattsAnnualOutput = pvwattsResponse;
        pvwattsDailyOutput = pvwattsResponse / 365;
        print('PVWatts Annual Output: $pvwattsAnnualOutput kWh');
        print('PVWatts Daily Output: $pvwattsDailyOutput kWh');

        // Calculate system size using PVWatts
        systemSizeKw = targetDailyConsumption / pvwattsDailyOutput;
        print('System Size (PVWatts): $systemSizeKw kW');
      } else {
        print('=== USING ESTIMATED CALCULATIONS ===');

        // Use new calculation method with conversion
        systemSizeKw = SolarCalculations.calculateSystemSizeWithConversion(
          monthlyBillValue: _monthlyBillValue,
          billOffsetPercentage: _billOffsetPercentage,
          sunHoursPerDay: _sunHoursPerDay,
          isPhpBilling: _usedPhpBilling,
          electricityRate: _electricityRate,
        );
        print('System Size (Estimated): $systemSizeKw kW');
      }

      // Calculate annual and monthly production
      double annualProduction;
      double monthlyProduction;

      if (_useApiIntegration && pvwattsAnnualOutput != null) {
        annualProduction = pvwattsAnnualOutput;
        monthlyProduction = pvwattsAnnualOutput / 12;
        print('Annual Production (PVWatts): $annualProduction kWh');
        print('Monthly Production (PVWatts): $monthlyProduction kWh');
      } else {
        annualProduction = systemSizeKw * _sunHoursPerDay * 365 * 0.75;
        monthlyProduction = annualProduction / 12;
        print('Annual Production (Estimated): $annualProduction kWh');
        print('Monthly Production (Estimated): $monthlyProduction kWh');
      }

      // Calculate solar panel cost and number of panels
      final solarPanelCost = SolarCalculations.calculateSolarPanelCost(
        systemSizeKw: systemSizeKw,
        panelSizeKw: _solarPanelSizeKw,
        panelPricePhp: _solarPanelPricePhp,
      );
      final numberOfPanels = SolarCalculations.calculateNumberOfPanels(
        systemSizeKw: systemSizeKw,
        panelSizeKw: _solarPanelSizeKw,
      );
      print('Solar Panel Cost: ₱$solarPanelCost');
      print('Number of Panels: $numberOfPanels');

      // Calculate battery cost and number of batteries (if off-grid/hybrid)
      double batteryCost = 0;
      int numberOfBatteries = 0;
      double batterySizeKwh = 0;

      if (_isOffGrid) {
        print('=== BATTERY CALCULATIONS ===');

        // Calculate battery size
        final dailyConsumption = _usedPhpBilling
            ? SolarCalculations.calculateDailyConsumption(
                SolarCalculations.convertPhpToKwh(
                monthlyBillPhp: _monthlyBillValue,
                electricityRate: _electricityRate,
              ))
            : SolarCalculations.calculateDailyConsumption(_monthlyBillValue);
        batterySizeKwh = SolarCalculations.calculateBatterySize(
          dailyEnergyConsumption: dailyConsumption,
          backupHours: _backupHours,
        );
        print('Battery Size: $batterySizeKwh kWh');

        // Calculate battery cost
        batteryCost = SolarCalculations.calculateBatteryCost(
          batterySizeKwh: batterySizeKwh,
          batterySizeKw: _batterySizeKwh,
          batteryPricePhp: _batteryPricePhp,
        );
        numberOfBatteries = SolarCalculations.calculateNumberOfBatteries(
          batterySizeKwh: batterySizeKwh,
          batterySizeKw: _batterySizeKwh,
        );
        print('Battery Cost: ₱$batteryCost');
        print('Number of Batteries: $numberOfBatteries');
      }

      // Calculate total system cost
      final totalSystemCost = SolarCalculations.calculateTotalSystemCost(
        solarPanelCost: solarPanelCost,
        includesBattery: _isOffGrid,
        batteryCost: batteryCost,
      );
      print('Total System Cost: ₱$totalSystemCost');

      // Calculate monthly savings
      final monthlySavings = SolarCalculations.calculateMonthlySavings(
        systemSizeKw: systemSizeKw,
        sunHoursPerDay:
            _useApiIntegration ? 4.5 : _sunHoursPerDay, // Use average for API
        electricityRate: _electricityRate,
      );
      print('Monthly Savings: ₱$monthlySavings');

      // Calculate payback period
      final paybackPeriod = totalSystemCost / monthlySavings;
      print('Payback Period: ${paybackPeriod.toStringAsFixed(1)} months');

      // Create calculation result
      _calculationResult = CalculationResultModel(
        systemSize: systemSizeKw,
        annualProduction: annualProduction,
        monthlyProduction: monthlyProduction,
        batterySize: batterySizeKwh,
        estimatedCost: totalSystemCost,
        sunHoursPerDay: _useApiIntegration ? null : _sunHoursPerDay,
        pvwattsAnnualOutput: pvwattsAnnualOutput,
        numberOfPanels: numberOfPanels,
        numberOfBatteries: numberOfBatteries,
        solarPanelCost: solarPanelCost,
        batteryCost: batteryCost,
      );

      print('=== CALCULATION COMPLETE ===');
      print('Result: $_calculationResult');
    } catch (e) {
      print('Calculation error: $e');
      _setError('Calculation failed: ${e.toString()}');
      _calculationResult = null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  // Step 2 Methods

  /// Update project details
  void updateProjectDetails(ProjectDetailsModel details) {
    _projectDetails = details;
    _markDataChanged();
    _clearError();

    // Update current quote with new project details if it exists
    if (_currentQuote != null) {
      _currentQuote = QuoteModel(
        id: _currentQuote!.id,
        projectName: details.projectName,
        clientName: details.clientName,
        projectLocation: details.location,
        systemSize: _currentQuote!.systemSize,
        isOffGrid: _currentQuote!.isOffGrid,
        batterySize: _currentQuote!.batterySize,
        rows: details.rows,
        createdAt: _currentQuote!.createdAt,
        updatedAt: DateTime.now(),
        totalPrice: details.totalCost,
        monthlyBillKwh: _currentQuote!.monthlyBillKwh,
        billOffsetPercentage: _currentQuote!.billOffsetPercentage,
        sunHoursPerDay: _currentQuote!.sunHoursPerDay,
        backupHours: _currentQuote!.backupHours,
        usedPhpBilling: _currentQuote!.usedPhpBilling,
        electricityRate: _currentQuote!.electricityRate,
      );
    }

    notifyListeners();
  }

  /// Add default rows based on calculation results
  List<ProjectRowModel> getDefaultRows() {
    if (_calculationResult == null) return [];

    final rows = <ProjectRowModel>[];

    // Add solar panels row
    // final solarPanelCost = SolarCalculations.calculateSolarPanelCost(
    //   systemSizeKw: _calculationResult!.systemSize,
    //   panelSizeKw: _solarPanelSizeKw,
    //   panelPricePhp: _solarPanelPricePhp,
    // );
    rows.add(
      ProjectRowModel(
        id: _uuid.v4(),
        title: 'Solar Panels (${_solarPanelSizeKw}kW)',
        quantity: _calculationResult!.numberOfPanels,
        unit: 'pcs',
        description: 'Solar Panels (${_solarPanelSizeKw}kW)',
        estimatedPrice: _solarPanelPricePhp,
        isAutoGenerated: true,
        category: 'solar_panels',
      ),
    );

    // Add battery row if off-grid
    if (_isOffGrid && _calculationResult!.batterySize > 0) {
      // final batteryCost = SolarCalculations.calculateBatteryCost(
      //   batterySizeKwh: _calculationResult!.batterySize,
      //   batterySizeKw: _batterySizeKwh,
      //   batteryPricePhp: _batteryPricePhp,
      // );
      rows.add(
        ProjectRowModel(
          id: _uuid.v4(),
          title: 'Lithium Battery (${_batterySizeKwh}kWh)',
          quantity: _calculationResult!.numberOfBatteries,
          unit: 'pcs',
          description: 'Lithium Battery (${_batterySizeKwh}kWh)',
          estimatedPrice: _batteryPricePhp,
          isAutoGenerated: true,
          category: 'battery',
        ),
      );
    }

    return rows;
  }

  // Navigation Methods

  /// Go to next step
  void nextStep() async {
    if (_currentStep < 3) {
      _currentStep++;
      _clearError();

      // Auto-generate PDF when entering step 3
      if (_currentStep == 3) {
        await _autoGeneratePdf();
      }

      notifyListeners();
    }
  }

  /// Go to previous step
  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      _clearError();
      notifyListeners();
    }
  }

  /// Go to specific step
  void goToStep(int step) async {
    if (step >= 1 && step <= 3) {
      _currentStep = step;
      _clearError();

      // Auto-generate PDF when entering step 3
      if (_currentStep == 3) {
        await _autoGeneratePdf();
      }

      notifyListeners();
    }
  }

  /// Auto-generate PDF when entering step 3
  Future<void> _autoGeneratePdf() async {
    try {
      // Create quote first if not exists
      if (_currentQuote == null) {
        await createQuote();
      }

      if (_currentQuote != null) {
        // Check if data has changed since last PDF generation
        if (_dataChanged || _generatedPdfFile == null) {
          print('Data changed or no PDF exists, regenerating PDF...');
          await generatePdf();
          _clearDataChanged(); // Clear the changed flag after successful generation
        } else {
          print('No data changes detected, using existing PDF');
        }
      }
    } catch (e) {
      // Don't show error for auto-generation, just log it
      print('Auto PDF generation failed: $e');
    }
  }

  // Step 3 Methods

  /// Create final quote
  Future<void> createQuote() async {
    try {
      if (_calculationResult == null || _projectDetails == null) {
        throw Exception('Missing calculation results or project details');
      }

      _isSaving = true;
      notifyListeners();

      // Create quote with all information
      _currentQuote = QuoteModel(
        id: _uuid.v4(),
        projectName: _projectDetails!.projectName,
        clientName: _projectDetails!.clientName,
        projectLocation: _projectDetails!.location,
        systemSize: _calculationResult!.systemSize,
        isOffGrid: _isOffGrid,
        batterySize: _calculationResult!.batterySize,
        rows: _projectDetails!.rows,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalPrice: _projectDetails!.totalCost,
        monthlyBillKwh: _monthlyBillKwh,
        billOffsetPercentage: _billOffsetPercentage,
        sunHoursPerDay: _calculationResult!.sunHoursPerDay ?? _sunHoursPerDay,
        backupHours: _isOffGrid ? _backupHours : null,
        usedPhpBilling: _usedPhpBilling,
        electricityRate: _usedPhpBilling ? _electricityRate : null,
      );

      // Save quote
      await _quoteRepository.saveQuote(_currentQuote!);
    } catch (e) {
      _setError('Failed to create quote: ${e.toString()}');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Generate PDF
  Future<void> generatePdf() async {
    try {
      _isGeneratingPdf = true;
      _clearError();
      notifyListeners();

      if (_currentQuote == null) {
        throw Exception('No quote available for PDF generation');
      }

      // Get company profile for PDF header
      final companyProfile =
          await _settingsRepository.getCompanyProfileWithDefaults();

      // Generate PDF using PdfService
      _generatedPdfFile = await PdfService.generateQuotePdf(
        _currentQuote!,
        companyProfile,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to generate PDF: ${e.toString()}');
    } finally {
      _isGeneratingPdf = false;
      notifyListeners();
    }
  }

  /// Share PDF with client
  Future<bool> sharePdf() async {
    try {
      if (_generatedPdfFile == null) {
        await generatePdf();
      }

      if (_generatedPdfFile != null) {
        final success = await ShareService.sharePdf(
          _generatedPdfFile!,
          'Solar Quotation - ${_currentQuote?.projectName ?? 'Project'}',
        );
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to share PDF: ${e.toString()}');
      return false;
    }
  }

  // Utility Methods

  /// Reset the entire quote generation process
  void resetQuoteGeneration() {
    _currentStep = 1;
    _monthlyBillKwh = 0;
    _monthlyBillValue = 0;
    _billOffsetPercentage = 80;
    _sunHoursPerDay = 4.5;
    _isOffGrid = false;
    _backupHours = 8;
    _usedPhpBilling = false;
    _electricityRate = 12.0;
    _calculationResult = null;
    _projectDetails = null;
    _currentQuote = null;
    _generatedPdfFile = null;
    _generatedImageFile = null;
    _clearError();
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
  }

  /// Clear error message (public method)
  void clearError() {
    _clearError();
    notifyListeners();
  }
}

/// Data class for step information
class StepInfo {
  final String title;
  final String description;

  const StepInfo({required this.title, required this.description});
}

/// Enum for progress states
enum ProgressState { inactive, active, completed }
