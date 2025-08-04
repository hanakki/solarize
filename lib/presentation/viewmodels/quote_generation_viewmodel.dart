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
import '../../core/services/pvwatts_service.dart';
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
  double _billOffsetPercentage = 80;
  double _sunHoursPerDay = 4.5;
  bool _isOffGrid = false;
  double _backupHours = 8;
  bool _usedPhpBilling = false;
  double _electricityRate = 12.0; // Default PHP rate per kWh
  bool _useApiIntegration = true; // Enable API integration by default

  // Location for PVWatts API (Philippines default)
  double _latitude = 10.3870; // Cebu coordinates
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
  double get billOffsetPercentage => _billOffsetPercentage;
  double get sunHoursPerDay => _sunHoursPerDay;
  bool get isOffGrid => _isOffGrid;
  double get backupHours => _backupHours;
  bool get usedPhpBilling => _usedPhpBilling;
  double get electricityRate => _electricityRate;
  bool get useApiIntegration => _useApiIntegration;
  double get latitude => _latitude;
  double get longitude => _longitude;
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
          title: 'Calculate System Size',
          description:
              'Let\'s start by estimating the ideal solar setup for your client.',
        );
      case 2:
        return const StepInfo(
          title: 'Enter Project Details',
          description:
              'Enter project-specific details to help us customize your solar quotation.',
        );
      case 3:
        return const StepInfo(
          title: 'Review Quotation & Send to Client',
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

  /// Update location coordinates
  void updateLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  /// Calculate system size and requirements using PVWatts API
  Future<void> calculateSystem() async {
    try {
      _isCalculating = true;
      _clearError();
      notifyListeners();

      // ===== DEBUG SECTION START - COMMENT OUT FOR PRODUCTION =====
      print('=== SOLAR CALCULATION DEBUG START ===');
      print('Input Variables:');
      print('  Monthly Bill (kWh): $_monthlyBillKwh');
      print('  Bill Offset (%): $_billOffsetPercentage');
      print('  Sun Hours/Day: $_sunHoursPerDay');
      print('  Is Off-Grid: $_isOffGrid');
      print('  Backup Hours: $_backupHours');
      print('  Used PHP Billing: $_usedPhpBilling');
      print('  Electricity Rate (₱/kWh): $_electricityRate');
      print('  Latitude: $_latitude');
      print('  Longitude: $_longitude');
      print('');

      // Validate inputs
      if (!SolarCalculations.validateCalculationInputs(
        monthlyBill: _monthlyBillKwh,
        billOffset: _billOffsetPercentage,
        sunHours: _sunHoursPerDay,
        backupHours: _isOffGrid ? _backupHours : null,
      )) {
        throw Exception('Invalid calculation inputs');
      }

      // Convert PHP to kWh if needed
      double actualMonthlyKwh = _monthlyBillKwh;
      if (_usedPhpBilling) {
        actualMonthlyKwh = SolarCalculations.convertPhpToKwh(
          monthlyBillPhp: _monthlyBillKwh,
          electricityRate: _electricityRate,
        );
        print('PHP to kWh Conversion:');
        print('  Monthly Bill (PHP): $_monthlyBillKwh');
        print('  Electricity Rate: $_electricityRate ₱/kWh');
        print('  Converted Monthly Bill (kWh): $actualMonthlyKwh');
        print(
          '  Formula: $_monthlyBillKwh ÷ $_electricityRate = $actualMonthlyKwh',
        );

        // Detailed conversion calculation
        final convertedKwh = _monthlyBillKwh / _electricityRate;
        final dailyKwh = convertedKwh / 30;
        final hourlyKwh = dailyKwh / 24;

        print('  Step-by-step conversion:');
        print('    Monthly bill (PHP): $_monthlyBillKwh ₱');
        print('    Electricity rate: $_electricityRate ₱/kWh');
        print(
          '    Monthly consumption: $_monthlyBillKwh ÷ $_electricityRate = ${convertedKwh.toStringAsFixed(2)} kWh',
        );
        print(
          '    Daily consumption: ${convertedKwh.toStringAsFixed(2)} ÷ 30 = ${dailyKwh.toStringAsFixed(2)} kWh',
        );
        print(
          '    Hourly consumption: ${dailyKwh.toStringAsFixed(2)} ÷ 24 = ${hourlyKwh.toStringAsFixed(2)} kWh',
        );
        print('    Final monthly kWh: $actualMonthlyKwh kWh');
        print('');
      } else {
        print('Using kWh directly: $actualMonthlyKwh');
        print('');
      }

      // Calculate initial system size estimate
      final estimatedSystemSize = SolarCalculations.calculateSystemSize(
        monthlyBillKwh: actualMonthlyKwh,
        billOffsetPercentage: _billOffsetPercentage,
        sunHoursPerDay: _sunHoursPerDay,
      );

      print('Initial System Size Calculation:');
      print('  Monthly Consumption: $actualMonthlyKwh kWh');
      print('  Bill Offset: $_billOffsetPercentage%');
      print('  Sun Hours/Day: $_sunHoursPerDay');
      print(
        '  Estimated System Size: ${estimatedSystemSize.toStringAsFixed(2)} kW',
      );

      // Detailed calculation breakdown
      final monthlyOffsetKwh = actualMonthlyKwh * (_billOffsetPercentage / 100);
      final dailyOffsetKwh = monthlyOffsetKwh / 30;
      final dailyProductionNeeded = dailyOffsetKwh / _sunHoursPerDay;

      print('  Step-by-step calculation:');
      print(
        '    Monthly offset needed: $actualMonthlyKwh × $_billOffsetPercentage% ÷ 100 = ${monthlyOffsetKwh.toStringAsFixed(2)} kWh',
      );
      print(
        '    Daily offset needed: ${monthlyOffsetKwh.toStringAsFixed(2)} ÷ 30 = ${dailyOffsetKwh.toStringAsFixed(2)} kWh',
      );
      print(
        '    System size needed: ${dailyOffsetKwh.toStringAsFixed(2)} ÷ $_sunHoursPerDay = ${dailyProductionNeeded.toStringAsFixed(2)} kW',
      );
      print(
        '    Final system size: ${estimatedSystemSize.toStringAsFixed(2)} kW',
      );
      print('');

      // Use API integration if enabled
      double annualProduction;
      double monthlyProduction;
      double systemSize;
      double requiredAnnualProduction;
      PVWattsResponse? pvwattsResponse;
      PVWattsResponse? finalPvwattsResponse;

      // Calculate required annual production (needed for both API and non-API modes)
      requiredAnnualProduction =
          actualMonthlyKwh * 12 * (_billOffsetPercentage / 100);

      if (_useApiIntegration) {
        // Call PVWatts API for accurate production data
        print('PVWatts API Call Parameters:');
        print(
          '  System Capacity: ${estimatedSystemSize.toStringAsFixed(2)} kW',
        );
        print('  Latitude: $_latitude');
        print('  Longitude: $_longitude');
        print('  Module Type: Standard (0)');
        print('  Array Type: Fixed Roof Mounted (1)');
        print('  Tilt: 15.0°');
        print('  Azimuth: 180.0° (South)');
        print('  System Losses: 14.0%');
        print('  DC/AC Ratio: 1.2');
        print('  Inverter Efficiency: 96.0%');
        print('');

        pvwattsResponse = await PVWattsService.calculateProduction(
          systemCapacity: estimatedSystemSize,
          latitude: _latitude,
          longitude: _longitude,
          moduleType: ModuleType.standard, // Standard modules
          arrayType: ArrayType.fixedRoofMounted, // Roof mounted
          tilt: 15.0, // Optimal tilt for Philippines
          azimuth: 180.0, // South facing
          losses: 14.0, // Standard system losses
          dcAcRatio: 1.2,
          invEff: 96.0,
        );

        // Check for API errors
        if (pvwattsResponse.hasErrors) {
          throw Exception('PVWatts API error: ${pvwattsResponse.firstError}');
        }

        // Get production data from PVWatts
        final pvwattsOutputs = pvwattsResponse.outputs;
        annualProduction = pvwattsOutputs.acAnnual;
        monthlyProduction = pvwattsOutputs.averageMonthlyProduction;

        print('PVWatts API Response:');
        print(
          '  Annual Production: ${annualProduction.toStringAsFixed(2)} kWh',
        );
        print(
          '  Monthly Production: ${monthlyProduction.toStringAsFixed(2)} kWh',
        );
        print(
          '  Capacity Factor: ${(pvwattsOutputs.capacityFactor * 100).toStringAsFixed(2)}%',
        );
        print(
          '  Solar Radiation: ${pvwattsOutputs.solradAnnual.toStringAsFixed(2)} kWh/m²/day',
        );
        print('');

        // Adjust system size based on actual production vs required
        final requiredAnnualProduction =
            actualMonthlyKwh * 12 * (_billOffsetPercentage / 100);
        systemSize =
            (requiredAnnualProduction / annualProduction) * estimatedSystemSize;
      } else {
        // Use estimated calculations without API
        print('API Integration Disabled - Using Estimated Calculations');
        print('  Using sun hours per day: $_sunHoursPerDay hours');

        // Calculate estimated production based on sun hours
        final dailyProduction =
            estimatedSystemSize * _sunHoursPerDay * 0.75; // 75% efficiency
        annualProduction = dailyProduction * 365;
        monthlyProduction = annualProduction / 12;
        systemSize = estimatedSystemSize; // No adjustment needed for estimates

        print('Estimated Production:');
        print('  Daily Production: ${dailyProduction.toStringAsFixed(2)} kWh');
        print(
          '  Annual Production: ${annualProduction.toStringAsFixed(2)} kWh',
        );
        print(
          '  Monthly Production: ${monthlyProduction.toStringAsFixed(2)} kWh',
        );
        print('  System Size: ${systemSize.toStringAsFixed(2)} kW');
        print('');
      }

      print('System Size Adjustment:');
      print(
        '  Required Annual Production: ${requiredAnnualProduction.toStringAsFixed(2)} kWh',
      );
      print(
        '  Formula: $actualMonthlyKwh × 12 × $_billOffsetPercentage% ÷ 100 = ${requiredAnnualProduction.toStringAsFixed(2)} kWh',
      );
      print(
        '  Actual Annual Production: ${annualProduction.toStringAsFixed(2)} kWh',
      );
      print(
        '  System Size Adjustment Factor: ${(requiredAnnualProduction / annualProduction).toStringAsFixed(4)}',
      );
      print('  Adjusted System Size: ${systemSize.toStringAsFixed(2)} kW');
      print(
        '  Formula: ${estimatedSystemSize.toStringAsFixed(2)} × ${(requiredAnnualProduction / annualProduction).toStringAsFixed(4)} = ${systemSize.toStringAsFixed(2)} kW',
      );

      // Detailed adjustment calculation
      final adjustmentFactor = requiredAnnualProduction / annualProduction;
      final adjustedSize = estimatedSystemSize * adjustmentFactor;

      print('  Step-by-step adjustment:');
      print(
        '    Required annual: $actualMonthlyKwh × 12 × $_billOffsetPercentage% ÷ 100 = ${requiredAnnualProduction.toStringAsFixed(2)} kWh',
      );
      print('    PVWatts annual: ${annualProduction.toStringAsFixed(2)} kWh');
      print(
        '    Adjustment factor: ${requiredAnnualProduction.toStringAsFixed(2)} ÷ ${annualProduction.toStringAsFixed(2)} = ${adjustmentFactor.toStringAsFixed(4)}',
      );
      print(
        '    Adjusted size: ${estimatedSystemSize.toStringAsFixed(2)} × ${adjustmentFactor.toStringAsFixed(4)} = ${adjustedSize.toStringAsFixed(2)} kW',
      );
      print('');

      // Recalculate with adjusted system size if needed
      if (_useApiIntegration &&
          (systemSize - estimatedSystemSize).abs() > 0.1) {
        print(
          'System size adjusted significantly, recalculating with PVWatts...',
        );
        finalPvwattsResponse = await PVWattsService.calculateProduction(
          systemCapacity: systemSize,
          latitude: _latitude,
          longitude: _longitude,
          moduleType: ModuleType.standard,
          arrayType: ArrayType.fixedRoofMounted,
          tilt: 15.0,
          azimuth: 180.0,
          losses: 14.0,
          dcAcRatio: 1.2,
          invEff: 96.0,
        );
        print('Final PVWatts Response:');
        print(
          '  Annual Production: ${finalPvwattsResponse?.outputs.acAnnual.toStringAsFixed(2)} kWh',
        );
        print(
          '  Monthly Production: ${finalPvwattsResponse?.outputs.averageMonthlyProduction.toStringAsFixed(2)} kWh',
        );
        print('');
      } else {
        print(
          'System size adjustment minimal, using original PVWatts response',
        );
        finalPvwattsResponse = pvwattsResponse;
        print('');
      }

      // Calculate battery size if off-grid
      double batterySize = 0;
      if (_isOffGrid) {
        final dailyConsumption = SolarCalculations.calculateDailyConsumption(
          actualMonthlyKwh,
        );
        batterySize = SolarCalculations.calculateBatterySize(
          dailyEnergyConsumption: dailyConsumption,
          backupHours: _backupHours,
        );

        print('Battery Calculation (Off-Grid):');
        print(
          '  Daily Consumption: ${dailyConsumption.toStringAsFixed(2)} kWh',
        );
        print(
          '  Formula: $actualMonthlyKwh ÷ 30 = ${dailyConsumption.toStringAsFixed(2)} kWh',
        );
        print('  Backup Hours: $_backupHours');
        print('  Battery Size: ${batterySize.toStringAsFixed(2)} kWh');
        print(
          '  Formula: ${dailyConsumption.toStringAsFixed(2)} × $_backupHours = ${batterySize.toStringAsFixed(2)} kWh',
        );

        // Detailed battery calculation
        final hourlyConsumption = dailyConsumption / 24;
        final batteryCapacityNeeded = hourlyConsumption * _backupHours;

        print('  Step-by-step battery calculation:');
        print('    Monthly consumption: $actualMonthlyKwh kWh');
        print(
          '    Daily consumption: $actualMonthlyKwh ÷ 30 = ${dailyConsumption.toStringAsFixed(2)} kWh',
        );
        print(
          '    Hourly consumption: ${dailyConsumption.toStringAsFixed(2)} ÷ 24 = ${hourlyConsumption.toStringAsFixed(2)} kWh',
        );
        print('    Backup hours needed: $_backupHours hours');
        print(
          '    Battery capacity: ${hourlyConsumption.toStringAsFixed(2)} × $_backupHours = ${batteryCapacityNeeded.toStringAsFixed(2)} kWh',
        );
        print('    Final battery size: ${batterySize.toStringAsFixed(2)} kWh');
        print('');
      } else {
        print('Grid-tied system - no battery required');
        print('');
      }

      // Calculate costs
      final estimatedCost = SolarCalculations.calculateTotalSystemCost(
        systemSizeKw: systemSize,
        includesBattery: _isOffGrid,
        batterySizeKwh: batterySize,
      );

      print('Cost Calculation:');
      print('  System Size: ${systemSize.toStringAsFixed(2)} kW');

      // Detailed cost breakdown
      final solarPanelCost = systemSize * 1000 * 45; // 45₱/W
      final installationCost = 50000.0;
      final batteryCost = _isOffGrid ? batterySize * 25000 : 0; // 25,000₱/kWh
      final totalCalculatedCost =
          solarPanelCost + installationCost + batteryCost;

      print('  Step-by-step cost calculation:');
      print(
        '    Solar panels: ${systemSize.toStringAsFixed(2)} kW × 1000 W/kW × 45₱/W = ${solarPanelCost.toStringAsFixed(2)} ₱',
      );
      print('    Installation: 50,000.00 ₱');
      if (_isOffGrid) {
        print(
          '    Battery: ${batterySize.toStringAsFixed(2)} kWh × 25,000₱/kWh = ${batteryCost.toStringAsFixed(2)} ₱',
        );
      } else {
        print('    Battery: Not required (grid-tied)');
      }
      print(
        '    Total: ${solarPanelCost.toStringAsFixed(2)} + 50,000.00 + ${batteryCost.toStringAsFixed(2)} = ${totalCalculatedCost.toStringAsFixed(2)} ₱',
      );
      print('    Final cost: ${estimatedCost.toStringAsFixed(2)} ₱');
      print('');

      // Calculate savings using production data
      double actualMonthlyProduction;
      if (_useApiIntegration && finalPvwattsResponse != null) {
        actualMonthlyProduction =
            finalPvwattsResponse.outputs.averageMonthlyProduction;
      } else {
        actualMonthlyProduction =
            monthlyProduction; // Use the calculated monthly production
      }
      final monthlySavings = actualMonthlyProduction * _electricityRate;

      print('Savings Calculation:');
      print(
        '  Monthly Production: ${actualMonthlyProduction.toStringAsFixed(2)} kWh',
      );
      print('  Electricity Rate: $_electricityRate ₱/kWh');
      print('  Monthly Savings: ${monthlySavings.toStringAsFixed(2)} ₱');
      print(
        '  Formula: ${actualMonthlyProduction.toStringAsFixed(2)} × $_electricityRate = ${monthlySavings.toStringAsFixed(2)} ₱',
      );

      // Detailed savings calculation
      final annualSavings = monthlySavings * 12;
      final dailySavings = monthlySavings / 30;

      print('  Step-by-step savings calculation:');
      print(
        '    Monthly production: ${actualMonthlyProduction.toStringAsFixed(2)} kWh (from PVWatts)',
      );
      print('    Electricity rate: $_electricityRate ₱/kWh');
      print(
        '    Monthly savings: ${actualMonthlyProduction.toStringAsFixed(2)} × $_electricityRate = ${monthlySavings.toStringAsFixed(2)} ₱',
      );
      print(
        '    Daily savings: ${monthlySavings.toStringAsFixed(2)} ÷ 30 = ${dailySavings.toStringAsFixed(2)} ₱',
      );
      print(
        '    Annual savings: ${monthlySavings.toStringAsFixed(2)} × 12 = ${annualSavings.toStringAsFixed(2)} ₱',
      );
      print('');

      final paybackPeriod = SolarCalculations.calculatePaybackPeriod(
        totalSystemCost: estimatedCost,
        monthlySavings: monthlySavings,
      );

      print('Payback Period Calculation:');
      print('  Total System Cost: ${estimatedCost.toStringAsFixed(2)} ₱');
      print('  Monthly Savings: ${monthlySavings.toStringAsFixed(2)} ₱');
      print('  Payback Period: ${paybackPeriod.toStringAsFixed(1)} years');
      print(
        '  Formula: ${estimatedCost.toStringAsFixed(2)} ÷ ${monthlySavings.toStringAsFixed(2)} ÷ 12 = ${paybackPeriod.toStringAsFixed(1)} years',
      );

      // Detailed payback calculation
      final annualSavingsForPayback = monthlySavings * 12;
      final calculatedPaybackPeriod = estimatedCost / annualSavingsForPayback;

      print('  Step-by-step payback calculation:');
      print('    Total system cost: ${estimatedCost.toStringAsFixed(2)} ₱');
      print('    Monthly savings: ${monthlySavings.toStringAsFixed(2)} ₱');
      print(
        '    Annual savings: ${monthlySavings.toStringAsFixed(2)} × 12 = ${annualSavingsForPayback.toStringAsFixed(2)} ₱',
      );
      print(
        '    Payback period: ${estimatedCost.toStringAsFixed(2)} ÷ ${annualSavingsForPayback.toStringAsFixed(2)} = ${calculatedPaybackPeriod.toStringAsFixed(1)} years',
      );
      print('    Final payback: ${paybackPeriod.toStringAsFixed(1)} years');
      print('');

      print('Final Results:');
      print('  System Size: ${systemSize.toStringAsFixed(2)} kW');
      print('  Battery Size: ${batterySize.toStringAsFixed(2)} kWh');
      print('  Total Cost: ${estimatedCost.toStringAsFixed(2)} ₱');
      print('  Monthly Savings: ${monthlySavings.toStringAsFixed(2)} ₱');
      print('  Payback Period: ${paybackPeriod.toStringAsFixed(1)} years');
      print('  Annual Production: ${annualProduction.toStringAsFixed(2)} kWh');
      print(
        '  Solar Radiation: ${_useApiIntegration && finalPvwattsResponse != null ? finalPvwattsResponse.outputs.solradAnnual.toStringAsFixed(2) : "N/A (estimated)"} kWh/m²/day',
      );
      print('=== SOLAR CALCULATION DEBUG END ===');
      // ===== DEBUG SECTION END - COMMENT OUT FOR PRODUCTION =====

      // Create calculation result with production data
      _calculationResult = CalculationResultModel(
        systemSize: systemSize,
        batterySize: batterySize,
        isOffGrid: _isOffGrid,
        estimatedCost: estimatedCost,
        monthlySavings: monthlySavings,
        paybackPeriod: paybackPeriod,
        monthlyBillKwh: actualMonthlyKwh,
        billOffsetPercentage: _billOffsetPercentage,
        sunHoursPerDay: _useApiIntegration && finalPvwattsResponse != null
            ? finalPvwattsResponse
                  .outputs
                  .solradAnnual // Use actual solar radiation from API
            : _sunHoursPerDay, // Use user input when API is disabled
      );
    } catch (e) {
      _setError('Calculation failed: ${e.toString()}');
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
    final solarPanelCost = SolarCalculations.calculateSolarPanelCost(
      _calculationResult!.systemSize,
    );
    rows.add(
      ProjectRowModel(
        id: _uuid.v4(),
        title: 'Solar Panels (250W Monocrystalline)',
        quantity: (_calculationResult!.systemSize * 4)
            .round(), // Assume 250W panels
        unit: 'pcs',
        description: 'Solar Panels (250W Monocrystalline)',
        estimatedPrice: solarPanelCost / (_calculationResult!.systemSize * 4),
        isAutoGenerated: true,
        category: 'solar_panels',
      ),
    );

    // Add battery row if off-grid
    if (_calculationResult!.isOffGrid && _calculationResult!.batterySize > 0) {
      final batteryCost = SolarCalculations.calculateBatteryCost(
        _calculationResult!.batterySize,
      );
      rows.add(
        ProjectRowModel(
          id: _uuid.v4(),
          title: 'Lithium Battery (2.4kWh)',
          quantity: (_calculationResult!.batterySize / 2.4)
              .ceil(), // Assume 2.4kWh per battery
          unit: 'pcs',
          description: 'Lithium Battery (2.4kWh)',
          estimatedPrice:
              batteryCost / (_calculationResult!.batterySize / 2.4).ceil(),
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
        isOffGrid: _calculationResult!.isOffGrid,
        batterySize: _calculationResult!.batterySize,
        rows: _projectDetails!.rows,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalPrice: _projectDetails!.totalCost,
        monthlyBillKwh: _calculationResult!.monthlyBillKwh,
        billOffsetPercentage: _calculationResult!.billOffsetPercentage,
        sunHoursPerDay: _calculationResult!.sunHoursPerDay,
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
      final companyProfile = await _settingsRepository
          .getCompanyProfileWithDefaults();

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

  /// Generate PNG image
  Future<void> generateImage() async {
    try {
      _isGeneratingImage = true;
      _clearError();
      notifyListeners();

      if (_currentQuote == null) {
        throw Exception('No quote available for image generation');
      }

      // TODO: Implement actual image generation
      // For now, we'll just simulate it
      await Future.delayed(const Duration(seconds: 2));

      notifyListeners();
    } catch (e) {
      _setError('Failed to generate image: ${e.toString()}');
    } finally {
      _isGeneratingImage = false;
      notifyListeners();
    }
  }

  // Utility Methods

  /// Reset the entire quote generation process
  void resetQuoteGeneration() {
    _currentStep = 1;
    _monthlyBillKwh = 0;
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
