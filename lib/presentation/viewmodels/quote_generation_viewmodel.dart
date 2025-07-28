import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/calculation_result_model.dart';
import '../../data/models/project_details_model.dart';
import '../../data/models/project_row_model.dart';
import '../../data/repositories/quote_repository.dart';
import '../../core/utils/calculations.dart';
import '../../core/constants/app_constants.dart';

/// ViewModel for the quote generation flow
/// Manages the 3-step quote creation process and calculations
class QuoteGenerationViewModel extends ChangeNotifier {
  final QuoteRepository _quoteRepository;
  final Uuid _uuid = const Uuid();

  QuoteGenerationViewModel(this._quoteRepository);

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
  double _sunHoursPerDay = 5.5;
  bool _isOffGrid = false;
  double _backupHours = 8;
  bool _usedPhpBilling = false;
  double _electricityRate = 12.0; // Default PHP rate per kWh

  // Calculation results
  CalculationResultModel? _calculationResult;

  // Step 2: Project details
  ProjectDetailsModel? _projectDetails;

  // Current quote being created
  QuoteModel? _currentQuote;

  // Error handling
  String? _errorMessage;

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
  CalculationResultModel? get calculationResult => _calculationResult;
  ProjectDetailsModel? get projectDetails => _projectDetails;
  QuoteModel? get currentQuote => _currentQuote;
  String? get errorMessage => _errorMessage;

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

  // Step 1 Methods

  /// Update monthly bill in kWh
  void updateMonthlyBillKwh(double value) {
    _monthlyBillKwh = value;
    _clearError();
    notifyListeners();
  }

  /// Update bill offset percentage
  void updateBillOffsetPercentage(double value) {
    _billOffsetPercentage = value;
    _clearError();
    notifyListeners();
  }

  /// Update sun hours per day
  void updateSunHoursPerDay(double value) {
    _sunHoursPerDay = value;
    _clearError();
    notifyListeners();
  }

  /// Toggle off-grid setup
  void toggleOffGrid(bool value) {
    _isOffGrid = value;
    _clearError();
    notifyListeners();
  }

  /// Update backup hours
  void updateBackupHours(double value) {
    _backupHours = value;
    _clearError();
    notifyListeners();
  }

  /// Toggle PHP billing mode
  void togglePhpBilling(bool value) {
    _usedPhpBilling = value;
    _clearError();
    notifyListeners();
  }

  /// Update electricity rate
  void updateElectricityRate(double value) {
    _electricityRate = value;
    _clearError();
    notifyListeners();
  }

  /// Calculate system size and requirements
  Future<void> calculateSystem() async {
    try {
      _isCalculating = true;
      _clearError();
      notifyListeners();

      // Simulate calculation delay
      await Future.delayed(const Duration(seconds: 2));

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
      }

      // Calculate system size
      final systemSize = SolarCalculations.calculateSystemSize(
        monthlyBillKwh: actualMonthlyKwh,
        billOffsetPercentage: _billOffsetPercentage,
        sunHoursPerDay: _sunHoursPerDay,
      );

      // Calculate battery size if off-grid
      double batterySize = 0;
      if (_isOffGrid) {
        final dailyConsumption =
            SolarCalculations.calculateDailyConsumption(actualMonthlyKwh);
        batterySize = SolarCalculations.calculateBatterySize(
          dailyEnergyConsumption: dailyConsumption,
          backupHours: _backupHours,
        );
      }

      // Calculate costs
      final estimatedCost = SolarCalculations.calculateTotalSystemCost(
        systemSizeKw: systemSize,
        includesBattery: _isOffGrid,
        batterySizeKwh: batterySize,
      );

      // Calculate savings and payback
      final monthlySavings = SolarCalculations.calculateMonthlySavings(
        systemSizeKw: systemSize,
        sunHoursPerDay: _sunHoursPerDay,
        electricityRate: _electricityRate,
      );

      final paybackPeriod = SolarCalculations.calculatePaybackPeriod(
        totalSystemCost: estimatedCost,
        monthlySavings: monthlySavings,
      );

      // Create calculation result
      _calculationResult = CalculationResultModel(
        systemSize: systemSize,
        batterySize: batterySize,
        isOffGrid: _isOffGrid,
        estimatedCost: estimatedCost,
        monthlySavings: monthlySavings,
        paybackPeriod: paybackPeriod,
        monthlyBillKwh: actualMonthlyKwh,
        billOffsetPercentage: _billOffsetPercentage,
        sunHoursPerDay: _sunHoursPerDay,
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
    _clearError();
    notifyListeners();
  }

  /// Add default rows based on calculation results
  List<ProjectRowModel> getDefaultRows() {
    if (_calculationResult == null) return [];

    final rows = <ProjectRowModel>[];

    // Add solar panels row
    final solarPanelCost = SolarCalculations.calculateSolarPanelCost(
        _calculationResult!.systemSize);
    rows.add(ProjectRowModel(
      id: _uuid.v4(),
      quantity:
          (_calculationResult!.systemSize * 4).round(), // Assume 250W panels
      unit: 'pcs',
      description: 'Solar Panels (250W Monocrystalline)',
      estimatedPrice: solarPanelCost / (_calculationResult!.systemSize * 4),
      isAutoGenerated: true,
      category: 'solar_panels',
    ));

    // Add battery row if off-grid
    if (_calculationResult!.isOffGrid && _calculationResult!.batterySize > 0) {
      final batteryCost = SolarCalculations.calculateBatteryCost(
          _calculationResult!.batterySize);
      rows.add(ProjectRowModel(
        id: _uuid.v4(),
        quantity: (_calculationResult!.batterySize / 2.4)
            .ceil(), // Assume 2.4kWh per battery
        unit: 'pcs',
        description: 'Lithium Battery (2.4kWh)',
        estimatedPrice:
            batteryCost / (_calculationResult!.batterySize / 2.4).ceil(),
        isAutoGenerated: true,
        category: 'battery',
      ));
    }

    return rows;
  }

  // Navigation Methods

  /// Go to next step
  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      _clearError();
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
  void goToStep(int step) {
    if (step >= 1 && step <= 3) {
      _currentStep = step;
      _clearError();
      notifyListeners();
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
      notifyListeners();

      // Simulate PDF generation
      await Future.delayed(const Duration(seconds: 3));

      // TODO: Implement actual PDF generation
    } catch (e) {
      _setError('Failed to generate PDF: ${e.toString()}');
    } finally {
      _isGeneratingPdf = false;
      notifyListeners();
    }
  }

  /// Generate PNG image
  Future<void> generateImage() async {
    try {
      _isGeneratingImage = true;
      notifyListeners();

      // Simulate image generation
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual image generation
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
    _sunHoursPerDay = 5.5;
    _isOffGrid = false;
    _backupHours = 8;
    _usedPhpBilling = false;
    _electricityRate = 12.0;
    _calculationResult = null;
    _projectDetails = null;
    _currentQuote = null;
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

  const StepInfo({
    required this.title,
    required this.description,
  });
}

/// Enum for progress states
enum ProgressState {
  inactive,
  active,
  completed,
}
