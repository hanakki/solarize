/// Model representing solar calculation results
class CalculationResultModel {
  final double systemSize; // in kW
  final double batterySize; // in kWh
  final bool isOffGrid;
  final double estimatedCost;
  final double monthlySavings;
  final double paybackPeriod;
  final double monthlyBillKwh;
  final double billOffsetPercentage;
  final double sunHoursPerDay;

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
  });

  /// Get system type description
  String get systemType => isOffGrid ? 'Off-Grid System' : 'Grid-Tied System';

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
    );
  }

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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculationResultModel &&
        other.systemSize == systemSize &&
        other.batterySize == batterySize &&
        other.isOffGrid == isOffGrid &&
        other.estimatedCost == estimatedCost &&
        other.monthlySavings == monthlySavings &&
        other.paybackPeriod == paybackPeriod &&
        other.monthlyBillKwh == monthlyBillKwh &&
        other.billOffsetPercentage == billOffsetPercentage &&
        other.sunHoursPerDay == sunHoursPerDay;
  }

  @override
  int get hashCode {
    return Object.hash(
      systemSize,
      batterySize,
      isOffGrid,
      estimatedCost,
      monthlySavings,
      paybackPeriod,
      monthlyBillKwh,
      billOffsetPercentage,
      sunHoursPerDay,
    );
  }

  @override
  String toString() {
    return 'CalculationResultModel(systemSize: $systemSize kW, estimatedCost: ₱$estimatedCost, paybackPeriod: $paybackPeriod years)';
  }
}
