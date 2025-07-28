import 'project_row_model.dart';

/// Model representing project details for quotes
class ProjectDetailsModel {
  final String projectName;
  final String clientName;
  final String location;
  final String installationDate;
  final List<ProjectRowModel> rows;

  const ProjectDetailsModel({
    required this.projectName,
    required this.clientName,
    required this.location,
    required this.installationDate,
    required this.rows,
  });

  /// Calculate total project cost
  double get totalCost => rows.fold(0.0, (sum, row) => sum + row.totalPrice);

  /// Get number of items
  int get itemCount => rows.length;

  /// Create a copy with updated values
  ProjectDetailsModel copyWith({
    String? projectName,
    String? clientName,
    String? location,
    String? installationDate,
    List<ProjectRowModel>? rows,
  }) {
    return ProjectDetailsModel(
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      location: location ?? this.location,
      installationDate: installationDate ?? this.installationDate,
      rows: rows ?? this.rows,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'clientName': clientName,
      'location': location,
      'installationDate': installationDate,
      'rows': rows.map((row) => row.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailsModel(
      projectName: json['projectName'] as String,
      clientName: json['clientName'] as String,
      location: json['location'] as String,
      installationDate: json['installationDate'] as String,
      rows: (json['rows'] as List)
          .map((row) => ProjectRowModel.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectDetailsModel &&
        other.projectName == projectName &&
        other.clientName == clientName &&
        other.location == location &&
        other.installationDate == installationDate &&
        other.rows.length == rows.length;
  }

  @override
  int get hashCode {
    return Object.hash(
      projectName,
      clientName,
      location,
      installationDate,
      rows.length,
    );
  }

  @override
  String toString() {
    return 'ProjectDetailsModel(projectName: $projectName, clientName: $clientName, totalCost: ₱$totalCost)';
  }
}
