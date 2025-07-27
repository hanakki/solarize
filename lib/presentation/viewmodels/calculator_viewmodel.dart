import 'package:flutter/material.dart';
import '../../data/models/calculation_result_model.dart';
import '../../core/utils/calculations.dart';

/// ViewModel for the advanced calculator
/// Handles complex solar calculations with additional parameters
class CalculatorViewModel extends ChangeNotifier {
  // Advanced calculation inputs
  double _systemSizeKw = 0;
  double _panelEfficiency = 20.0; // Percentage
  double _inverterEfficiency = 95.0; // Percentage
  double _systemLosses = 15.0; // Percentage
  double _tiltAngle = 15.0; // Degrees
  double _azimuthAngle = 180.0; // Degrees (South facing)
  double _temperatureCoefficient = -0.4; // %/°C
  double _averageTemperature = 30.0; // °C
  double _irradiance = 5.5; // kWh/m²/day
  double _shadingLosses = 5.0; // Percentage
  double _soilingLosses = 2.0; // Percentage
  double _electricityRate = 12.0; // PHP per kWh

  // Battery parameters (for off-grid calculations)
  bool _includesBattery = false;
  double _batteryCapacityKwh = 0;
  double _batteryEfficiency = 90.0; // Percentage
  double _depthOfDischarge = 80.0; // Percentage
  int _autonomyDays = 3; // Days of backup

  // Economic parameters
  double _systemCostPerWatt = 45.0; // PHP per watt
  double _installationCost = 50000.0; // PHP
  double _maintenanceCostPerYear = 5000.0; // PHP
  double _electricityInflationRate = 5.0; // Percentage per year
  int _systemLifespan = 25; // Years

  // Calculation results
  CalculationResultModel? _calculationResult;
  Map<String, double>? _detailedResults;

  // State
  bool _isCalculating = false;
  String? _errorMessage;

  // Getters
  double get systemSizeKw => _systemSizeKw;
  double get panelEfficiency => _panelEfficiency;
  double get inverterEfficiency => _inverterEfficiency;
  double get systemLosses => _systemLosses;
  double get tiltAngle => _tiltAngle;
  double get azimuthAngle => _azimuthAngle;
  double get temperatureCoefficient => _temperatureCoefficient;
  double get averageTemperature => _averageTemperature;
  double get irradiance => _irradiance;
  double get shadingLosses => _shadingLosses;
  double get soilingLosses => _soilingLosses;
  double get electricityRate => _electricityRate;
  bool get includesBattery => _includesBattery;
  double get batteryCapacityKwh => _batteryCapacityKwh;
  double get batteryEfficiency => _batteryEfficiency;
  double get depthOfDischarge => _depthOfDischarge;
  int get autonomyDays => _autonomyDays;
  double get systemCostPerWatt => _systemCostPerWatt;
  double get installationCost => _installationCost;
  double get maintenanceCostPerYear => _maintenanceCostPerYear;
  double get electricityInflationRate => _electricityInflationRate;
  int get systemLifespan => _systemLifespan;
  CalculationResultModel? get calculationResult => _calculationResult;
  Map<String, double>? get detailedResults => _detailedResults;
  bool get isCalculating => _isCalculating;
  String? get errorMessage => _errorMessage;

  // Setters
  void updateSystemSize(double value) {
    _systemSizeKw = value;
    _clearError();
    notifyListeners();
  }

  void updatePanelEfficiency(double value) {
    _panelEfficiency = value;
    _clearError();
    notifyListeners();
  }

  void updateInverterEfficiency(double value) {
    _inverterEfficiency = value;
    _clearError();
    notifyListeners();
  }

  void updateSystemLosses(double value) {
    _systemLosses = value;
    _clearError();
    notifyListeners();
  }

  void updateTiltAngle(double value) {
    _tiltAngle = value;
    _clearError();
    notifyListeners();
  }

  void updateAzimuthAngle(double value) {
    _azimuthAngle = value;
    _clearError();
    notifyListeners();
  }

  void updateTemperatureCoefficient(double value) {
    _temperatureCoefficient = value;
    _clearError();
    notifyListeners();
  }

  void updateAverageTemperature(double value) {
    _averageTemperature = value;
    _clearError();
    notifyListeners();
  }

  void updateIrradiance(double value) {
    _irradiance = value;
    _clearError();
    notifyListeners();
  }

  void updateShadingLosses(double value) {
    _shadingLosses = value;
    _clearError();
    notifyListeners();
  }

  void updateSoilingLosses(double value) {
    _soilingLosses = value;
    _clearError();
    notifyListeners();
  }

  void updateElectricityRate(double value) {
    _electricityRate = value;
    _clearError();
    notifyListeners();
  }

  void toggleBattery(bool value) {
    _includesBattery = value;
    _clearError();
    notifyListeners();
  }

  void updateBatteryCapacity(double value) {
    _batteryCapacityKwh = value;
    _clearError();
    notifyListeners();
  }

  void updateBatteryEfficiency(double value) {
    _batteryEfficiency = value;
    _clearError();
    notifyListeners();
  }

  void updateDepthOfDischarge(double value) {
    _depthOfDischarge = value;
    _clearError();
    notifyListeners();
  }

  void updateAutonomyDays(int value) {
    _autonomyDays = value;
    _clearError();
    notifyListeners();
  }

  void updateSystemCostPerWatt(double value) {
    _systemCostPerWatt = value;
    _clearError();
    notifyListeners();
  }

  void updateInstallationCost(double value) {
    _installationCost = value;
    _clearError();
    notifyListeners();
  }

  void updateMaintenanceCost(double value) {
    _maintenanceCostPerYear = value;
    _clearError();
    notifyListeners();
  }

  void updateElectricityInflationRate(double value) {
    _electricityInflationRate = value;
    _clearError();
    notifyListeners();
  }

  void updateSystemLifespan(int value) {
    _systemLifespan = value;
    _clearError();
    notifyListeners();
  }

  /// Perform advanced solar calculations
  Future<void> calculateAdvanced() async {
    try {
      _isCalculating = true;
      _clearError();
      notifyListeners();

      // Simulate calculation delay
      await Future.delayed(const Duration(seconds: 3));

      // Validate inputs
      if (_systemSizeKw <= 0) {
        throw Exception('System size must be greater than 0');
      }

      if (_irradiance <= 0) {
        throw Exception('Solar irradiance must be greater than 0');
      }

      // Calculate temperature derating
      final temperatureDerating =
          1 + (_temperatureCoefficient / 100) * (_averageTemperature - 25);

      // Calculate total system losses
      final totalLosses =
          1 - ((_systemLosses + _shadingLosses + _soilingLosses) / 100);

      // Calculate panel area (assuming 200W/m² panel power density)
      final panelAreaM2 = (_systemSizeKw * 1000) / 200;

      // Calculate daily energy production
      final dailyEnergyProduction = _systemSizeKw *
          _irradiance *
          (_panelEfficiency / 100) *
          (_inverterEfficiency / 100) *
          temperatureDerating *
          totalLosses;

      // Calculate monthly and annual production
      final monthlyEnergyProduction = dailyEnergyProduction * 30;
      final annualEnergyProduction = dailyEnergyProduction * 365;

      // Calculate battery requirements if included
      double batterySize = _batteryCapacityKwh;
      if (_includesBattery && batterySize <= 0) {
        // Auto-calculate battery size based on autonomy days
        batterySize = (dailyEnergyProduction * _autonomyDays) /
            ((_depthOfDischarge / 100) * (_batteryEfficiency / 100));
      }

      // Calculate costs
      final systemCost = _systemSizeKw * 1000 * _systemCostPerWatt;
      final batteryCost =
          _includesBattery ? batterySize * 25000 : 0; // ₱25,000 per kWh
      final totalSystemCost = systemCost + batteryCost + _installationCost;

      // Calculate savings
      final monthlySavings = monthlyEnergyProduction * _electricityRate;
      final annualSavings = annualEnergyProduction * _electricityRate;

      // Calculate payback period
      final paybackPeriod =
          totalSystemCost / (annualSavings - _maintenanceCostPerYear);

      // Calculate NPV and IRR (simplified)
      final totalLifetimeSavings = _calculateLifetimeSavings(annualSavings);
      final netPresentValue = totalLifetimeSavings - totalSystemCost;

      // Create detailed results
      _detailedResults = {
        'dailyProduction': dailyEnergyProduction,
        'monthlyProduction': monthlyEnergyProduction,
        'annualProduction': annualEnergyProduction,
        'systemCost': systemCost,
        'batteryCost': batteryCost,
        'installationCost': _installationCost,
        'totalSystemCost': totalSystemCost,
        'monthlySavings': monthlySavings,
        'annualSavings': annualSavings,
        'paybackPeriod': paybackPeriod,
        'netPresentValue': netPresentValue,
        'panelArea': panelAreaM2,
        'temperatureDerating': temperatureDerating,
        'totalLosses': totalLosses,
        'lifetimeSavings': totalLifetimeSavings,
      };

      // Create calculation result
      _calculationResult = CalculationResultModel(
        systemSize: _systemSizeKw,
        batterySize: batterySize,
        isOffGrid: _includesBattery,
        estimatedCost: totalSystemCost,
        monthlySavings: monthlySavings,
        paybackPeriod: paybackPeriod,
        monthlyBillKwh:
            monthlyEnergyProduction, // Using production as reference
        billOffsetPercentage: 100, // Assuming full offset for advanced calc
        sunHoursPerDay: _irradiance,
      );
    } catch (e) {
      _setError('Advanced calculation failed: ${e.toString()}');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  /// Calculate lifetime savings with inflation
  double _calculateLifetimeSavings(double annualSavings) {
    double totalSavings = 0;
    double currentSavings = annualSavings;

    for (int year = 1; year <= _systemLifespan; year++) {
      totalSavings += currentSavings - _maintenanceCostPerYear;
      currentSavings *= (1 + _electricityInflationRate / 100);
    }

    return totalSavings;
  }

  /// Reset all parameters to defaults
  void resetToDefaults() {
    _systemSizeKw = 0;
    _panelEfficiency = 20.0;
    _inverterEfficiency = 95.0;
    _systemLosses = 15.0;
    _tiltAngle = 15.0;
    _azimuthAngle = 180.0;
    _temperatureCoefficient = -0.4;
    _averageTemperature = 30.0;
    _irradiance = 5.5;
    _shadingLosses = 5.0;
    _soilingLosses = 2.0;
    _electricityRate = 12.0;
    _includesBattery = false;
    _batteryCapacityKwh = 0;
    _batteryEfficiency = 90.0;
    _depthOfDischarge = 80.0;
    _autonomyDays = 3;
    _systemCostPerWatt = 45.0;
    _installationCost = 50000.0;
    _maintenanceCostPerYear = 5000.0;
    _electricityInflationRate = 5.0;
    _systemLifespan = 25;
    _calculationResult = null;
    _detailedResults = null;
    _clearError();
    notifyListeners();
  }

  /// Get parameter recommendations based on location (Philippines)
  void applyPhilippinesDefaults() {
    _tiltAngle = 15.0; // Optimal for Philippines latitude
    _azimuthAngle = 180.0; // South facing
    _averageTemperature = 28.0; // Average temperature in Philippines
    _irradiance = 5.2; // Average solar irradiance in Philippines
    _electricityRate = 12.0; // Average electricity rate in Philippines
    _systemCostPerWatt = 45.0; // Current market rate in Philippines
    notifyListeners();
  }

  // Utility Methods

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

  /// Validate all inputs
  bool validateInputs() {
    if (_systemSizeKw <= 0) return false;
    if (_panelEfficiency <= 0 || _panelEfficiency > 100) return false;
    if (_inverterEfficiency <= 0 || _inverterEfficiency > 100) return false;
    if (_irradiance <= 0) return false;
    if (_electricityRate <= 0) return false;
    if (_includesBattery && _batteryCapacityKwh <= 0 && _autonomyDays <= 0)
      return false;

    return true;
  }
}
