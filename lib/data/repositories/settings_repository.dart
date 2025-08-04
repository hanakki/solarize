import '../../data/models/company_profile_model.dart';
import '../../core/services/local_storage_service.dart';

/// Repository for managing app settings and company profile
/// Handles company information storage and retrieval
class SettingsRepository {
  final LocalStorageService _storageService;

  SettingsRepository(this._storageService);

  /// Get company profile with defaults
  Future<CompanyProfileModel> getCompanyProfileWithDefaults() async {
    try {
      final profile = await _storageService.getSettings();
      if (profile != null) {
        return profile;
      }

      // Return default profile if none exists
      return _getDefaultCompanyProfile();
    } catch (e) {
      // Return default profile if there's an error
      return _getDefaultCompanyProfile();
    }
  }

  /// Save company profile
  Future<void> saveCompanyProfile(CompanyProfileModel profile) async {
    await _storageService.saveSettings(profile);
  }

  /// Reset company profile to defaults
  Future<void> resetCompanyProfile() async {
    final defaultProfile = _getDefaultCompanyProfile();
    await _storageService.saveSettings(defaultProfile);
  }

  /// Get default company profile
  CompanyProfileModel _getDefaultCompanyProfile() {
    return const CompanyProfileModel(
      companyName: 'Your Solar Company',
      logoPath: null,
      address: '123 Solar Street, Green City, Philippines',
      phoneNumber: '+63 912 345 6789',
      telephoneNumber: '+63 32 123 4567',
      email: 'info@yoursolarcompany.com',
      website: 'https://yoursolarcompany.com',
      footerNotes: 'Thank you for choosing sustainable energy solutions.',
      preparedBy: 'Solar Consultant',
    );
  }

  /// Check if company profile exists
  Future<bool> hasCompanyProfile() async {
    try {
      final profile = await _storageService.getSettings();
      return profile != null;
    } catch (e) {
      return false;
    }
  }

  /// Get company name
  Future<String> getCompanyName() async {
    final profile = await getCompanyProfileWithDefaults();
    return profile.companyName;
  }

  /// Get logo path
  Future<String?> getLogoPath() async {
    final profile = await getCompanyProfileWithDefaults();
    return profile.logoPath;
  }

  /// Update logo path
  Future<void> updateLogoPath(String? logoPath) async {
    final profile = await getCompanyProfileWithDefaults();
    final updatedProfile = profile.copyWith(logoPath: logoPath);
    await saveCompanyProfile(updatedProfile);
  }

  /// Get contact information
  Future<Map<String, String?>> getContactInfo() async {
    final profile = await getCompanyProfileWithDefaults();
    return {
      'address': profile.address,
      'phoneNumber': profile.phoneNumber,
      'telephoneNumber': profile.telephoneNumber,
      'email': profile.email,
      'website': profile.website,
    };
  }

  /// Get footer information
  Future<Map<String, String?>> getFooterInfo() async {
    final profile = await getCompanyProfileWithDefaults();
    return {
      'footerNotes': profile.footerNotes,
      'preparedBy': profile.preparedBy,
    };
  }
}
