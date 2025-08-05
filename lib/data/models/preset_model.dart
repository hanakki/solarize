import 'project_row_model.dart';

/// Model class representing a reusable preset template
/// Contains default rows that can be applied to new quotes
class PresetModel {
  final String id;
  final String name;
  final List<ProjectRowModel> defaultRows;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault; // System-provided presets vs user-created

  const PresetModel({
    required this.id,
    required this.name,
    required this.defaultRows,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
  });

  /// Create a copy of the preset with updated values
  PresetModel copyWith({
    String? id,
    String? name,
    List<ProjectRowModel>? defaultRows,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
  }) {
    return PresetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultRows: defaultRows ?? this.defaultRows,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Calculate total estimated price of all rows in preset
  double get totalEstimatedPrice {
    return defaultRows.fold(0.0, (sum, row) => sum + row.totalPrice);
  }

  /// Get number of items in preset
  int get itemCount => defaultRows.length;

  /// Convert preset to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'defaultRows': defaultRows.map((row) => row.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  /// Create preset from JSON
  factory PresetModel.fromJson(Map<String, dynamic> json) {
    return PresetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      defaultRows: (json['defaultRows'] as List)
          .map((row) => ProjectRowModel.fromJson(row as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'PresetModel(id: $id, name: $name, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PresetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
