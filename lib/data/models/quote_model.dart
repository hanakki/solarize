import 'project_row_model.dart';

class QuoteModel {
  final String id;
  final String projectName;
  final String clientName;
  final String projectLocation;
  final double systemSize;
  final bool isOffGrid;
  final double batterySize;
  final List<ProjectRowModel> rows;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalPrice;

  final double monthlyBillKwh;
  final double billOffsetPercentage;
  final double sunHoursPerDay;
  final double? backupHours;
  final bool usedPhpBilling;
  final double? electricityRate;

  const QuoteModel({
    required this.id,
    required this.projectName,
    required this.clientName,
    required this.projectLocation,
    required this.systemSize,
    required this.isOffGrid,
    required this.batterySize,
    required this.rows,
    required this.createdAt,
    required this.updatedAt,
    required this.totalPrice,
    required this.monthlyBillKwh,
    required this.billOffsetPercentage,
    required this.sunHoursPerDay,
    this.backupHours,
    this.usedPhpBilling = false,
    this.electricityRate,
  });

  QuoteModel copyWith({
    String? id,
    String? projectName,
    String? clientName,
    String? projectLocation,
    double? systemSize,
    bool? isOffGrid,
    double? batterySize,
    List<ProjectRowModel>? rows,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalPrice,
    double? monthlyBillKwh,
    double? billOffsetPercentage,
    double? sunHoursPerDay,
    double? backupHours,
    bool? usedPhpBilling,
    double? electricityRate,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      projectLocation: projectLocation ?? this.projectLocation,
      systemSize: systemSize ?? this.systemSize,
      isOffGrid: isOffGrid ?? this.isOffGrid,
      batterySize: batterySize ?? this.batterySize,
      rows: rows ?? this.rows,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalPrice: totalPrice ?? this.totalPrice,
      monthlyBillKwh: monthlyBillKwh ?? this.monthlyBillKwh,
      billOffsetPercentage: billOffsetPercentage ?? this.billOffsetPercentage,
      sunHoursPerDay: sunHoursPerDay ?? this.sunHoursPerDay,
      backupHours: backupHours ?? this.backupHours,
      usedPhpBilling: usedPhpBilling ?? this.usedPhpBilling,
      electricityRate: electricityRate ?? this.electricityRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectName': projectName,
      'clientName': clientName,
      'projectLocation': projectLocation,
      'systemSize': systemSize,
      'isOffGrid': isOffGrid,
      'batterySize': batterySize,
      'rows': rows.map((row) => row.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalPrice': totalPrice,
      'monthlyBillKwh': monthlyBillKwh,
      'billOffsetPercentage': billOffsetPercentage,
      'sunHoursPerDay': sunHoursPerDay,
      'backupHours': backupHours,
      'usedPhpBilling': usedPhpBilling,
      'electricityRate': electricityRate,
    };
  }

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      projectName: json['projectName'] as String,
      clientName: json['clientName'] as String,
      projectLocation: json['projectLocation'] as String,
      systemSize: (json['systemSize'] as num).toDouble(),
      isOffGrid: json['isOffGrid'] as bool,
      batterySize: (json['batterySize'] as num).toDouble(),
      rows: (json['rows'] as List)
          .map((row) => ProjectRowModel.fromJson(row as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
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
    return 'QuoteModel(id: $id, projectName: $projectName, clientName: $clientName, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
