/// Model class representing company profile information
/// Used for PDF generation and app settings
class CompanyProfileModel {
  final String companyName;
  final String? logoPath;
  final String? address;
  final String? phoneNumber;
  final String? telephoneNumber;
  final String? email;
  final String? website;
  final String? footerNotes;
  final String? preparedBy;

  const CompanyProfileModel({
    required this.companyName,
    this.logoPath,
    this.address,
    this.phoneNumber,
    this.telephoneNumber,
    this.email,
    this.website,
    this.footerNotes,
    this.preparedBy,
  });

  /// Create a copy with updated values
  CompanyProfileModel copyWith({
    String? companyName,
    String? logoPath,
    String? address,
    String? phoneNumber,
    String? telephoneNumber,
    String? email,
    String? website,
    String? footerNotes,
    String? preparedBy,
  }) {
    return CompanyProfileModel(
      companyName: companyName ?? this.companyName,
      logoPath: logoPath ?? this.logoPath,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      telephoneNumber: telephoneNumber ?? this.telephoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      footerNotes: footerNotes ?? this.footerNotes,
      preparedBy: preparedBy ?? this.preparedBy,
    );
  }

  /// Check if company has logo
  bool get hasLogo => logoPath != null && logoPath!.isNotEmpty;

  /// Get display name for prepared by field
  String get displayPreparedBy => preparedBy ?? 'Solar Consultant';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'logoPath': logoPath,
      'address': address,
      'phoneNumber': phoneNumber,
      'telephoneNumber': telephoneNumber,
      'email': email,
      'website': website,
      'footerNotes': footerNotes,
      'preparedBy': preparedBy,
    };
  }

  /// Create from JSON
  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      companyName: json['companyName'] as String,
      logoPath: json['logoPath'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      telephoneNumber: json['telephoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      footerNotes: json['footerNotes'] as String?,
      preparedBy: json['preparedBy'] as String?,
    );
  }

  @override
  String toString() {
    return 'CompanyProfileModel(companyName: $companyName, preparedBy: $preparedBy)';
  }
}
