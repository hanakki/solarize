import '../../data/models/company_profile_model.dart';
import '../../core/services/local_storage_service.dart';

// Handles company information storage and retrieval
class SettingsRepository {
  final LocalStorageService _storageService;

  SettingsRepository(this._storageService);

  Future<CompanyProfileModel> getCompanyProfileWithDefaults() async {
    try {
      final profile = await _storageService.getSettings();
      if (profile != null) {
        return profile;
      }

      return _getDefaultCompanyProfile();
    } catch (e) {
      return _getDefaultCompanyProfile();
    }
  }

  Future<void> saveCompanyProfile(CompanyProfileModel profile) async {
    await _storageService.saveSettings(profile);
  }

  Future<void> resetCompanyProfile() async {
    final defaultProfile = _getDefaultCompanyProfile();
    await _storageService.saveSettings(defaultProfile);
  }

  CompanyProfileModel _getDefaultCompanyProfile() {
    return const CompanyProfileModel(
      companyName: 'Solar Company',
      logoPath: null,
      address: 'Toledo City, Cebu, Philippines',
      phoneNumber: '+63 912 345 6789',
      telephoneNumber: '+63 32 123 4567',
      email: 'info@yoursolarcompany.com',
      website: 'https://yoursolarcompany.com',
      footerNotes: 'Thank you for choosing sustainable energy solutions.',
      preparedBy: 'Solar Consultant',
    );
  }
}
