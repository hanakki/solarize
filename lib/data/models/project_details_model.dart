import 'project_row_model.dart';

/// Model class representing project details for Step 2 of quote generation
/// Contains client information and project-specific data
class ProjectDetailsModel {
  final String projectName;
  final String clientName;
  final String projectLocation;
  final List<ProjectRowModel> rows;
  final String? notes;

  const ProjectDetailsModel({
    required this.projectName,
    required this.clientName,
    required this.projectLocation,
    required this.rows,
    this.notes,
  });

  /// Create a copy with updated values
  ProjectDetailsModel copyWith({
    String? projectName,
    String? clientName,
    String? projectLocation,
    List<ProjectRowModel>? rows,
    String? notes,
  }) {
    return ProjectDetailsModel(
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      projectLocation: projectLocation ?? this.projectLocation,
      rows: rows ?? this.rows,
      notes: notes ?? this.notes,
    );
  }

  /// Calculate total price of all rows
  double get totalPrice {
    return rows.fold(0.0, (sum, row) => sum + row.totalPrice);
  }

  /// Get number of items
  int get itemCount => rows.length;

  /// Check if all required fields are filled
  bool get isValid {
    return projectName.trim().isNotEmpty &&
        clientName.trim().isNotEmpty &&
        projectLocation.trim().isNotEmpty &&
        rows.isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'clientName': clientName,
      'projectLocation': projectLocation,
      'rows': rows.map((row) => row.toJson()).toList(),
      'notes': notes,
    };
  }

  /// Create from JSON
  factory ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailsModel(
      projectName: json['projectName'] as String,
      clientName: json['clientName'] as String,
      projectLocation: json['projectLocation'] as String,
      rows: (json['rows'] as List)
          .map((row) => ProjectRowModel.fromJson(row as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'ProjectDetailsModel(projectName: $projectName, clientName: $clientName, itemCount: $itemCount)';
  }
}
