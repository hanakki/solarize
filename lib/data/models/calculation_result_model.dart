/// Model class representing the results of solar system calculations
/// Used to pass calculation results between screens
class CalculationResultModel {
  final double systemSize; // in kW
  final double batterySize; // in kWh (0 if grid-tied)
  final bool isOffGrid;
  final double estimatedCost;
  final double monthlySavings;
  final double paybackPeriod; // in years

  // Input parameters used for calculation
  final double monthlyBillKwh;
  final double billOffsetPercentage;
  final double sunHoursPerDay;
  final double? backupHours;
  final bool usedPhpBilling;
  final double? electricityRate;

  const CalculationResultModel({
    required this.systemSize,
    required this.batterySize,
    required this.isOffGrid,
    required this.estimatedCost,
    required this.monthlySavings,
    required this.paybackPeriod,
    required this.monthlyBillKwh,
    required this.billOffsetPercentage,
    required this.sunHoursPerDay,
    this.backupHours,
    this.usedPhpBilling = false,
    this.electricityRate,
  });

  /// Create a copy with updated values
  CalculationResultModel copyWith({
    double? systemSize,
    double? batterySize,
    bool? isOffGrid,
    double? estimatedCost,
    double? monthlySavings,
    double? paybackPeriod,
    double? monthlyBillKwh,
    double? billOffsetPercentage,
    double? sunHoursPerDay,
    double? backupHours,
    bool? usedPhpBilling,
    double? electricityRate,
  }) {
    return CalculationResultModel(
      systemSize: systemSize ?? this.systemSize,
      batterySize: batterySize ?? this.batterySize,
      isOffGrid: isOffGrid ?? this.isOffGrid,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      monthlySavings: monthlySavings ?? this.monthlySavings,
      paybackPeriod: paybackPeriod ?? this.paybackPeriod,
      monthlyBillKwh: monthlyBillKwh ?? this.monthlyBillKwh,
      billOffsetPercentage: billOffsetPercentage ?? this.billOffsetPercentage,
      sunHoursPerDay: sunHoursPerDay ?? this.sunHoursPerDay,
      backupHours: backupHours ?? this.backupHours,
      usedPhpBilling: usedPhpBilling ?? this.usedPhpBilling,
      electricityRate: electricityRate ?? this.electricityRate,
    );
  }

  /// Get system type as string
  String get systemType => isOffGrid ? 'Off-Grid/Hybrid' : 'Grid-Tied';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'systemSize': systemSize,
      'batterySize': batterySize,
      'isOffGrid': isOffGrid,
      'estimatedCost': estimatedCost,
      'monthlySavings': monthlySavings,
      'paybackPeriod': paybackPeriod,
      'monthlyBillKwh': monthlyBillKwh,
      'billOffsetPercentage': billOffsetPercentage,
      'sunHoursPerDay': sunHoursPerDay,
      'backupHours': backupHours,
      'usedPhpBilling': usedPhpBilling,
      'electricityRate': electricityRate,
    };
  }

  /// Create from JSON
  factory CalculationResultModel.fromJson(Map<String, dynamic> json) {
    return CalculationResultModel(
      systemSize: (json['systemSize'] as num).toDouble(),
      batterySize: (json['batterySize'] as num).toDouble(),
      isOffGrid: json['isOffGrid'] as bool,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      monthlySavings: (json['monthlySavings'] as num).toDouble(),
      paybackPeriod: (json['paybackPeriod'] as num).toDouble(),
      monthlyBillKwh: (json['monthlyBillKwh'] as num).toDouble(),
      billOffsetPercentage: (json['billOffsetPercentage'] as num).toDouble(),
      sunHoursPerDay: (json['sunHoursPerDay'] as num).toDouble(),
      backupHours: json['backupHours'] != null
          ? (json['backupHours'] as num).toDouble()
          : null,
      usedPhpBilling: json['usedPhpBilling'] as bool? ?? false,
      electricityRate: json['electricityRate'] != null
          ? (json['electricityRate'] as num).toDouble()
          : null,
    );
  }

  @override
  String toString() {
    return 'CalculationResultModel(systemSize: $systemSize kW, batterySize: $batterySize kWh, cost: ₱$estimatedCost)';
  }
}
