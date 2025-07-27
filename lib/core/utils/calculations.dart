import '../constants/app_constants.dart';

/// Utility class for solar system calculations
/// Contains all formulas and logic for system sizing and pricing
class SolarCalculations {
  
  /// Calculate system size based on monthly consumption and requirements
  /// Formula: (Electric Bill (kWh) × Bill Offset Percentage × Power Factor) / (30 × Sun Hours per Day)
  static double calculateSystemSize({
    required double monthlyBillKwh,
    required double billOffsetPercentage,
    required double sunHoursPerDay,
  }) {
    if (monthlyBillKwh <= 0 || sunHoursPerDay <= 0) {
      throw ArgumentError('Monthly bill and sun hours must be greater than 0');
    }
    
    final systemSize = (monthlyBillKwh * (billOffsetPercentage / 100) * AppConstants.powerFactor) / 
                     (AppConstants.daysInMonth * sunHoursPerDay);
    
    return double.parse(systemSize.toStringAsFixed(2));
  }
  
  /// Calculate battery size for off-grid/hybrid systems
  /// Formula: (Daily Energy Consumption (kWh) × Backup Hours) / (DoD × Efficiency)
  static double calculateBatterySize({
    required double dailyEnergyConsumption,
    required double backupHours,
  }) {
    if (dailyEnergyConsumption <= 0 || backupHours <= 0) {
      throw ArgumentError('Daily consumption and backup hours must be greater than 0');
    }
    
    final batterySize = (dailyEnergyConsumption * backupHours) / 
                       (AppConstants.depthOfDischarge * AppConstants.batteryEfficiency);
    
    return double.parse(batterySize.toStringAsFixed(2));
  }
  
  /// Calculate daily energy consumption from monthly bill
  static double calculateDailyConsumption(double monthlyBillKwh) {
    return monthlyBillKwh / AppConstants.daysInMonth;
  }
  
  /// Convert PHP bill to kWh using electricity rate
  static double convertPhpToKwh({
    required double monthlyBillPhp,
    required double electricityRate,
  }) {
    if (electricityRate <= 0) {
      throw ArgumentError('Electricity rate must be greater than 0');
    }
    
    return monthlyBillPhp / electricityRate;
  }
  
  /// Calculate solar panel cost
  static double calculateSolarPanelCost(double systemSizeKw) {
    return systemSizeKw * 1000 * AppConstants.solarPanelPricePerWatt; // Convert kW to W
  }
  
  /// Calculate battery cost
  static double calculateBatteryCost(double batterySizeKwh) {
    return batterySizeKwh * AppConstants.batteryPricePerKwh;
  }
  
  /// Calculate total system cost including panels and battery
  static double calculateTotalSystemCost({
    required double systemSizeKw,
    required bool includesBattery,
    double batterySizeKwh = 0,
  }) {
    double totalCost = calculateSolarPanelCost(systemSizeKw);
    
    if (includesBattery && batterySizeKwh > 0) {
      totalCost += calculateBatteryCost(batterySizeKwh);
    }
    
    return double.parse(totalCost.toStringAsFixed(2));
  }
  
  /// Validate calculation inputs
  static bool validateCalculationInputs({
    required double monthlyBill,
    required double billOffset,
    required double sunHours,
    double? backupHours,
  }) {
    if (monthlyBill <= 0) return false;
    if (billOffset < 0 || billOffset > 100) return false;
    if (sunHours <= 0 || sunHours > 24) return false;
    if (backupHours != null && (backupHours < 0 || backupHours > 24)) return false;
    
    return true;
  }
  
  /// Get recommended system size range
  static Map<String, double> getRecommendedSystemRange(double calculatedSize) {
    return {
      'minimum': double.parse((calculatedSize * 0.8).toStringAsFixed(2)),
      'recommended': calculatedSize,
      'maximum': double.parse((calculatedSize * 1.2).toStringAsFixed(2)),
    };
  }
  
  /// Calculate estimated monthly savings
  static double calculateMonthlySavings({
    required double systemSizeKw,
    required double sunHoursPerDay,
    required double electricityRate,
  }) {
    final monthlyGeneration = systemSizeKw * sunHoursPerDay * AppConstants.daysInMonth;
    return monthlyGeneration * electricityRate;
  }
  
  /// Calculate payback period in years
  static double calculatePaybackPeriod({
    required double totalSystemCost,
    required double monthlySavings,
  }) {
    if (monthlySavings <= 0) return 0;
    
    final annualSavings = monthlySavings * 12;
    return double.parse((totalSystemCost / annualSavings).toStringAsFixed(1));
  }
}
