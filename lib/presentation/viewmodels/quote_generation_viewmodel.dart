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

class QuoteGenerationViewModel extends ChangeNotifier {
  final QuoteRepository _quoteRepository;
  final SettingsRepository _settingsRepository;
  final Uuid _uuid = const Uuid();

  QuoteGenerationViewModel(this._quoteRepository, this._settingsRepository);

  int _currentStep = 1;

  bool _isCalculating = false;
  bool _isSaving = false;
  bool _isGeneratingPdf = false;

  double _monthlyBillKwh = 0;
  double _monthlyBillValue = 0;
  double _billOffsetPercentage = 80;
  double _sunHoursPerDay = 4.5;
  bool _isOffGrid = false;
  double _backupHours = 8;
  bool _usedPhpBilling = false;
  double _electricityRate = 14.0;
  bool _useApiIntegration = true;

  double _solarPanelSizeKw = 1.0;
  double _solarPanelPricePhp = 40000.0;

  double _batterySizeKwh = 5.0;
  double _batteryPricePhp = 125000.0;

  double _latitude = 10.387; // Toledo City coordinates
  double _longitude = 123.6502;

  CalculationResultModel? _calculationResult;

  ProjectDetailsModel? _projectDetails;

  QuoteModel? _currentQuote;

  File? _generatedPdfFile;

  String? _errorMessage;

  bool _dataChanged = false;

  int get currentStep => _currentStep;
  bool get isCalculating => _isCalculating;
  bool get isSaving => _isSaving;
  bool get isGeneratingPdf => _isGeneratingPdf;
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

  double get solarPanelSizeKw => _solarPanelSizeKw;
  double get solarPanelPricePhp => _solarPanelPricePhp;

  double get batterySizeKwh => _batterySizeKwh;
  double get batteryPricePhp => _batteryPricePhp;

  CalculationResultModel? get calculationResult => _calculationResult;
  ProjectDetailsModel? get projectDetails => _projectDetails;
  QuoteModel? get currentQuote => _currentQuote;
  File? get generatedPdfFile => _generatedPdfFile;
  String? get errorMessage => _errorMessage;
  bool get dataChanged => _dataChanged;

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

  ProgressState getProgressState(int step) {
    if (step < _currentStep) return ProgressState.completed;
    if (step == _currentStep) return ProgressState.active;
    return ProgressState.inactive;
  }

  void _markDataChanged() {
    _dataChanged = true;
  }

  void _clearDataChanged() {
    _dataChanged = false;
  }

  void updateMonthlyBillKwh(double value) {
    _monthlyBillKwh = value;
    _monthlyBillValue = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateMonthlyBillPhp(double value) {
    _monthlyBillValue = value;
    if (_electricityRate > 0) {
      _monthlyBillKwh = value / _electricityRate;
    }
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateBillOffsetPercentage(double value) {
    _billOffsetPercentage = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateSunHoursPerDay(double value) {
    _sunHoursPerDay = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void toggleOffGrid(bool value) {
    _isOffGrid = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateBackupHours(double value) {
    _backupHours = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void togglePhpBilling(bool value) {
    _usedPhpBilling = value;
    if (value && _monthlyBillKwh > 0 && _electricityRate > 0) {
      _monthlyBillValue = _monthlyBillKwh * _electricityRate;
    } else if (!value && _monthlyBillValue > 0 && _electricityRate > 0) {
      _monthlyBillKwh = _monthlyBillValue / _electricityRate;
    }
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void toggleApiIntegration(bool value) {
    _useApiIntegration = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateElectricityRate(double value) {
    _electricityRate = value;
    if (_usedPhpBilling && _monthlyBillValue > 0 && value > 0) {
      _monthlyBillKwh = _monthlyBillValue / value;
    }
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateSolarPanelSize(double value) {
    _solarPanelSizeKw = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateSolarPanelPrice(double value) {
    _solarPanelPricePhp = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateBatterySize(double value) {
    _batterySizeKwh = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateBatteryPrice(double value) {
    _batteryPricePhp = value;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  void updateLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    _markDataChanged();
    _clearError();
    notifyListeners();
  }

  Future<void> calculateSystem() async {
    if (_monthlyBillKwh <= 0 || _billOffsetPercentage <= 0) {
      _setError('Please provide valid monthly bill and bill offset percentage');
      return;
    }

    try {
      _isCalculating = true;
      _clearError();
      notifyListeners();

      double systemSizeKw;
      double? pvwattsAnnualOutput;
      double? pvwattsDailyOutput;

      if (_useApiIntegration) {
        final targetDailyConsumption =
            SolarCalculations.calculateTargetDailyConsumptionWithConversion(
          monthlyBillValue: _monthlyBillValue,
          billOffsetPercentage: _billOffsetPercentage,
          isPhpBilling: _usedPhpBilling,
          electricityRate: _electricityRate,
        );
        print('Target Daily Consumption: $targetDailyConsumption kWh');

        final pvwattsResponse = await SolarCalculations.getPvwattsAnnualOutput(
          latitude: _latitude,
          longitude: _longitude,
        );
        pvwattsAnnualOutput = pvwattsResponse;
        pvwattsDailyOutput = pvwattsResponse / 365;
        print('PVWatts Annual Output: $pvwattsAnnualOutput kWh');
        print('PVWatts Daily Output: $pvwattsDailyOutput kWh');

        systemSizeKw = targetDailyConsumption / pvwattsDailyOutput;
        print('System Size (PVWatts): $systemSizeKw kW');
      } else {
        print('=== USING ESTIMATED CALCULATIONS ===');

        systemSizeKw = SolarCalculations.calculateSystemSizeWithConversion(
          monthlyBillValue: _monthlyBillValue,
          billOffsetPercentage: _billOffsetPercentage,
          sunHoursPerDay: _sunHoursPerDay,
          isPhpBilling: _usedPhpBilling,
          electricityRate: _electricityRate,
        );
        print('System Size (Estimated): $systemSizeKw kW');
      }

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

      double batteryCost = 0;
      int numberOfBatteries = 0;
      double batterySizeKwh = 0;

      if (_isOffGrid) {
        print('=== BATTERY CALCULATIONS ===');

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

      final totalSystemCost = SolarCalculations.calculateTotalSystemCost(
        solarPanelCost: solarPanelCost,
        includesBattery: _isOffGrid,
        batteryCost: batteryCost,
      );
      print('Total System Cost: ₱$totalSystemCost');

      final monthlySavings = SolarCalculations.calculateMonthlySavings(
        systemSizeKw: systemSizeKw,
        sunHoursPerDay: _useApiIntegration ? 4.5 : _sunHoursPerDay,
        electricityRate: _electricityRate,
      );
      print('Monthly Savings: ₱$monthlySavings');

      final paybackPeriod = totalSystemCost / monthlySavings;
      print('Payback Period: ${paybackPeriod.toStringAsFixed(1)} months');

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

  void updateProjectDetails(ProjectDetailsModel details) {
    _projectDetails = details;
    _markDataChanged();
    _clearError();

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

  List<ProjectRowModel> getDefaultRows() {
    if (_calculationResult == null) return [];

    final rows = <ProjectRowModel>[];

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

    if (_isOffGrid && _calculationResult!.batterySize > 0) {
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

  void nextStep() async {
    if (_currentStep < 3) {
      _currentStep++;
      _clearError();

      if (_currentStep == 3) {
        await _autoGeneratePdf();
      }

      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      _clearError();
      notifyListeners();
    }
  }

  void goToStep(int step) async {
    if (step >= 1 && step <= 3) {
      _currentStep = step;
      _clearError();

      if (_currentStep == 3) {
        await _autoGeneratePdf();
      }

      notifyListeners();
    }
  }

  Future<void> _autoGeneratePdf() async {
    try {
      if (_currentQuote == null) {
        await createQuote();
      }

      if (_currentQuote != null) {
        if (_dataChanged || _generatedPdfFile == null) {
          print('Data changed or no PDF exists, regenerating PDF...');
          await generatePdf();
          _clearDataChanged();
        } else {
          print('No data changes detected, using existing PDF');
        }
      }
    } catch (e) {
      print('Auto PDF generation failed: $e');
    }
  }

  Future<void> createQuote() async {
    try {
      if (_calculationResult == null || _projectDetails == null) {
        throw Exception('Missing calculation results or project details');
      }

      _isSaving = true;
      notifyListeners();

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

      await _quoteRepository.saveQuote(_currentQuote!);
    } catch (e) {
      _setError('Failed to create quote: ${e.toString()}');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> generatePdf() async {
    try {
      _isGeneratingPdf = true;
      _clearError();
      notifyListeners();

      if (_currentQuote == null) {
        throw Exception('No quote available for PDF generation');
      }

      final companyProfile =
          await _settingsRepository.getCompanyProfileWithDefaults();

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
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
  }
}

class StepInfo {
  final String title;
  final String description;

  const StepInfo({required this.title, required this.description});
}

enum ProgressState { inactive, active, completed }
