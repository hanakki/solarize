class CalculationResultModel {
  final double systemSize;
  final double annualProduction;
  final double monthlyProduction;
  final double batterySize;
  final double estimatedCost;
  final double? sunHoursPerDay;
  final double? pvwattsAnnualOutput;

  final int numberOfPanels;
  final int numberOfBatteries;
  final double solarPanelCost;
  final double batteryCost;

  const CalculationResultModel({
    required this.systemSize,
    required this.annualProduction,
    required this.monthlyProduction,
    required this.batterySize,
    required this.estimatedCost,
    this.sunHoursPerDay,
    this.pvwattsAnnualOutput,
    required this.numberOfPanels,
    required this.numberOfBatteries,
    required this.solarPanelCost,
    required this.batteryCost,
  });

  String get systemType =>
      batterySize > 0 ? 'Off-Grid/Hybrid System' : 'Grid-Tied System';

  CalculationResultModel copyWith({
    double? systemSize,
    double? annualProduction,
    double? monthlyProduction,
    double? batterySize,
    double? estimatedCost,
    double? sunHoursPerDay,
    double? pvwattsAnnualOutput,
    int? numberOfPanels,
    int? numberOfBatteries,
    double? solarPanelCost,
    double? batteryCost,
  }) {
    return CalculationResultModel(
      systemSize: systemSize ?? this.systemSize,
      annualProduction: annualProduction ?? this.annualProduction,
      monthlyProduction: monthlyProduction ?? this.monthlyProduction,
      batterySize: batterySize ?? this.batterySize,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      sunHoursPerDay: sunHoursPerDay ?? this.sunHoursPerDay,
      pvwattsAnnualOutput: pvwattsAnnualOutput ?? this.pvwattsAnnualOutput,
      numberOfPanels: numberOfPanels ?? this.numberOfPanels,
      numberOfBatteries: numberOfBatteries ?? this.numberOfBatteries,
      solarPanelCost: solarPanelCost ?? this.solarPanelCost,
      batteryCost: batteryCost ?? this.batteryCost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systemSize': systemSize,
      'annualProduction': annualProduction,
      'monthlyProduction': monthlyProduction,
      'batterySize': batterySize,
      'estimatedCost': estimatedCost,
      'sunHoursPerDay': sunHoursPerDay,
      'pvwattsAnnualOutput': pvwattsAnnualOutput,
      'numberOfPanels': numberOfPanels,
      'numberOfBatteries': numberOfBatteries,
      'solarPanelCost': solarPanelCost,
      'batteryCost': batteryCost,
    };
  }

  factory CalculationResultModel.fromJson(Map<String, dynamic> json) {
    return CalculationResultModel(
      systemSize: (json['systemSize'] as num).toDouble(),
      annualProduction: (json['annualProduction'] as num).toDouble(),
      monthlyProduction: (json['monthlyProduction'] as num).toDouble(),
      batterySize: (json['batterySize'] as num).toDouble(),
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      sunHoursPerDay: json['sunHoursPerDay'] as double?,
      pvwattsAnnualOutput: json['pvwattsAnnualOutput'] as double?,
      numberOfPanels: json['numberOfPanels'] as int,
      numberOfBatteries: json['numberOfBatteries'] as int,
      solarPanelCost: (json['solarPanelCost'] as num).toDouble(),
      batteryCost: (json['batteryCost'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculationResultModel &&
        other.systemSize == systemSize &&
        other.annualProduction == annualProduction &&
        other.monthlyProduction == monthlyProduction &&
        other.batterySize == batterySize &&
        other.estimatedCost == estimatedCost &&
        other.sunHoursPerDay == sunHoursPerDay &&
        other.pvwattsAnnualOutput == pvwattsAnnualOutput &&
        other.numberOfPanels == numberOfPanels &&
        other.numberOfBatteries == numberOfBatteries &&
        other.solarPanelCost == solarPanelCost &&
        other.batteryCost == batteryCost;
  }

  @override
  int get hashCode {
    return Object.hash(
      systemSize,
      annualProduction,
      monthlyProduction,
      batterySize,
      estimatedCost,
      sunHoursPerDay,
      pvwattsAnnualOutput,
      numberOfPanels,
      numberOfBatteries,
      solarPanelCost,
      batteryCost,
    );
  }

  @override
  String toString() {
    return 'CalculationResultModel(systemSize: $systemSize kW, estimatedCost: ₱$estimatedCost, panels: $numberOfPanels, batteries: $numberOfBatteries)';
  }
}
