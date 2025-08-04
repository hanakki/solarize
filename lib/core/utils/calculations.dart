import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Utility class for solar system calculations
/// Contains all formulas and logic for system sizing and pricing
class SolarCalculations {
  /// Calculate target daily consumption
  /// Formula: (Electric Bill in kWh × Offset %) ÷ Days per Month
  static double calculateTargetDailyConsumption({
    required double monthlyBillKwh,
    required double billOffsetPercentage,
  }) {
    if (monthlyBillKwh <= 0 || billOffsetPercentage <= 0) {
      throw ArgumentError(
          'Monthly bill and bill offset must be greater than 0');
    }

    final targetDailyConsumption =
        (monthlyBillKwh * (billOffsetPercentage / 100)) /
            AppConstants.daysInMonth;
    return double.parse(targetDailyConsumption.toStringAsFixed(2));
  }

  /// Calculate target daily consumption with automatic PHP to kWh conversion
  /// Formula: (Monthly Bill (kWh) × Bill Offset Percentage) / Days in Month
  static double calculateTargetDailyConsumptionWithConversion({
    required double monthlyBillValue,
    required double billOffsetPercentage,
    required bool isPhpBilling,
    required double electricityRate,
  }) {
    if (monthlyBillValue <= 0 || billOffsetPercentage <= 0) {
      throw ArgumentError(
          'Monthly bill and bill offset must be greater than 0');
    }

    if (isPhpBilling && electricityRate <= 0) {
      throw ArgumentError(
          'Electricity rate must be greater than 0 for PHP billing');
    }

    // Convert PHP to kWh if needed
    final monthlyBillKwh = isPhpBilling
        ? convertPhpToKwh(
            monthlyBillPhp: monthlyBillValue, electricityRate: electricityRate)
        : monthlyBillValue;

    final targetDailyConsumption =
        (monthlyBillKwh * (billOffsetPercentage / 100)) /
            AppConstants.daysInMonth;
    return double.parse(targetDailyConsumption.toStringAsFixed(2));
  }

  /// Get PVWatts API data for a specific location
  /// Returns the ac_annual value from PVWatts API
  static Future<double> getPvwattsAnnualOutput({
    required double latitude,
    required double longitude,
  }) async {
    try {
      const String baseUrl = 'https://developer.nrel.gov/api/pvwatts/v8';
      const String apiKey = 'DEMO_KEY'; // Replace with your actual API key

      // Build query parameters with fixed constants
      final queryParams = {
        'format': 'json',
        'api_key': apiKey,
        'system_capacity': AppConstants.pvwattsSystemCapacity.toString(),
        'module_type': AppConstants.pvwattsModuleType.toString(),
        'array_type': AppConstants.pvwattsArrayType.toString(),
        'tilt': AppConstants.pvwattsTilt.toString(),
        'azimuth': AppConstants.pvwattsAzimuth.toString(),
        'losses': AppConstants.pvwattsLosses.toString(),
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'timeframe': AppConstants.pvwattsTimeframe,
      };

      // Build URL
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      // Make API call
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check for API errors
        if (data['errors'] != null && (data['errors'] as List).isNotEmpty) {
          throw Exception('PVWatts API error: ${data['errors']}');
        }

        // Get ac_annual from outputs
        final outputs = data['outputs'];
        if (outputs != null && outputs['ac_annual'] != null) {
          return (outputs['ac_annual'] as num).toDouble();
        } else {
          throw Exception('No ac_annual data in PVWatts response');
        }
      } else {
        throw Exception(
            'PVWatts API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get PVWatts data: $e');
    }
  }

  /// Calculate system size using PVWatts data
  /// Formula: Target Daily Consumption ÷ PVWatts Daily Output
  static Future<double> calculateSystemSizeWithPvwatts({
    required double monthlyBillKwh,
    required double billOffsetPercentage,
    required double latitude,
    required double longitude,
  }) async {
    // Calculate target daily consumption
    final targetDailyConsumption = calculateTargetDailyConsumption(
      monthlyBillKwh: monthlyBillKwh,
      billOffsetPercentage: billOffsetPercentage,
    );

    // Get PVWatts annual output
    final pvwattsAnnualOutput = await getPvwattsAnnualOutput(
      latitude: latitude,
      longitude: longitude,
    );

    // Calculate PVWatts daily output
    final pvwattsDailyOutput = pvwattsAnnualOutput / 365;

    // Calculate system size
    final systemSize = targetDailyConsumption / pvwattsDailyOutput;

    return double.parse(systemSize.toStringAsFixed(2));
  }

  /// Calculate system size based on monthly consumption and requirements (legacy method)
  /// Formula: (Electric Bill (kWh) × Bill Offset Percentage × Power Factor) / (30 × Sun Hours per Day)
  static double calculateSystemSize({
    required double monthlyBillKwh,
    required double billOffsetPercentage,
    required double sunHoursPerDay,
  }) {
    if (monthlyBillKwh <= 0 || sunHoursPerDay <= 0) {
      throw ArgumentError('Monthly bill and sun hours must be greater than 0');
    }

    final systemSize = (monthlyBillKwh *
            (billOffsetPercentage / 100) *
            AppConstants.powerFactor) /
        (AppConstants.daysInMonth * sunHoursPerDay);

    return double.parse(systemSize.toStringAsFixed(2));
  }

  /// Calculate system size with automatic PHP to kWh conversion
  /// Formula: (Electric Bill (kWh) × Bill Offset Percentage × Power Factor) / (30 × Sun Hours per Day)
  static double calculateSystemSizeWithConversion({
    required double monthlyBillValue,
    required double billOffsetPercentage,
    required double sunHoursPerDay,
    required bool isPhpBilling,
    required double electricityRate,
  }) {
    if (monthlyBillValue <= 0 || sunHoursPerDay <= 0) {
      throw ArgumentError('Monthly bill and sun hours must be greater than 0');
    }

    if (isPhpBilling && electricityRate <= 0) {
      throw ArgumentError(
          'Electricity rate must be greater than 0 for PHP billing');
    }

    // Convert PHP to kWh if needed
    final monthlyBillKwh = isPhpBilling
        ? convertPhpToKwh(
            monthlyBillPhp: monthlyBillValue, electricityRate: electricityRate)
        : monthlyBillValue;

    final systemSize = (monthlyBillKwh * (billOffsetPercentage / 100)) /
        (AppConstants.powerFactor * AppConstants.daysInMonth * sunHoursPerDay);

    return double.parse(systemSize.toStringAsFixed(2));
  }

  /// Calculate battery size for off-grid/hybrid systems
  /// Formula: (Daily Energy Consumption (kWh) × Backup Hours) / (DoD × Efficiency)
  static double calculateBatterySize({
    required double dailyEnergyConsumption,
    required double backupHours,
  }) {
    if (dailyEnergyConsumption <= 0 || backupHours <= 0) {
      throw ArgumentError(
          'Daily consumption and backup hours must be greater than 0');
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

  /// Calculate solar panel cost using user-defined panel size and price
  static double calculateSolarPanelCost({
    required double systemSizeKw,
    required double panelSizeKw,
    required double panelPricePhp,
  }) {
    if (systemSizeKw <= 0 || panelSizeKw <= 0 || panelPricePhp <= 0) {
      throw ArgumentError(
          'System size, panel size, and panel price must be greater than 0');
    }

    // Calculate number of panels needed
    final numberOfPanels = (systemSizeKw / panelSizeKw).ceil();
    final totalCost = numberOfPanels * panelPricePhp;

    return double.parse(totalCost.toStringAsFixed(2));
  }

  /// Calculate number of solar panels needed
  static int calculateNumberOfPanels({
    required double systemSizeKw,
    required double panelSizeKw,
  }) {
    if (systemSizeKw <= 0 || panelSizeKw <= 0) {
      throw ArgumentError('System size and panel size must be greater than 0');
    }

    return (systemSizeKw / panelSizeKw).ceil();
  }

  /// Calculate battery cost using user-defined battery size and price
  static double calculateBatteryCost({
    required double batterySizeKwh,
    required double batterySizeKw,
    required double batteryPricePhp,
  }) {
    if (batterySizeKwh <= 0 || batterySizeKw <= 0 || batteryPricePhp <= 0) {
      throw ArgumentError('Battery size and price must be greater than 0');
    }

    // Calculate number of batteries needed
    final numberOfBatteries = (batterySizeKwh / batterySizeKw).ceil();
    final totalCost = numberOfBatteries * batteryPricePhp;

    return double.parse(totalCost.toStringAsFixed(2));
  }

  /// Calculate number of batteries needed
  static int calculateNumberOfBatteries({
    required double batterySizeKwh,
    required double batterySizeKw,
  }) {
    if (batterySizeKwh <= 0 || batterySizeKw <= 0) {
      throw ArgumentError('Battery size must be greater than 0');
    }

    return (batterySizeKwh / batterySizeKw).ceil();
  }

  /// Calculate total system cost including panels and battery
  static double calculateTotalSystemCost({
    required double solarPanelCost,
    required bool includesBattery,
    double batteryCost = 0,
  }) {
    double totalCost = solarPanelCost;

    if (includesBattery && batteryCost > 0) {
      totalCost += batteryCost;
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
    if (backupHours != null && (backupHours < 0 || backupHours > 24))
      return false;

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
    final dailyProduction =
        systemSizeKw * sunHoursPerDay * AppConstants.systemEfficiency;
    final monthlyProduction = dailyProduction * 30;
    final monthlySavings = monthlyProduction * electricityRate;

    return double.parse(monthlySavings.toStringAsFixed(2));
  }
}
