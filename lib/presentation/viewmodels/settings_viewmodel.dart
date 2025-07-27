import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/company_profile_model.dart';
import '../../data/repositories/settings_repository.dart';

/// ViewModel for app settings and company profile management
/// Handles company information, logo upload, and app preferences
class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  SettingsViewModel(this._settingsRepository);

  // Company profile data
  CompanyProfileModel? _companyProfile;

  // State variables
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  String? _errorMessage;
  String? _successMessage;

  // Form controllers (for UI binding)
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController telephoneNumberController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController footerNotesController = TextEditingController();
  final TextEditingController preparedByController = TextEditingController();

  // Getters
  CompanyProfileModel? get companyProfile => _companyProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingLogo => _isUploadingLogo;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasLogo => _companyProfile?.hasLogo ?? false;
  String? get logoPath => _companyProfile?.logoPath;

  /// Initialize settings (load company profile)
  Future<void> initialize() async {
    await loadCompanyProfile();
  }

  /// Load company profile from storage
  Future<void> loadCompanyProfile() async {
    try {
      _isLoading = true;
      _clearMessages();
      notifyListeners();

      _companyProfile =
          await _settingsRepository.getCompanyProfileWithDefaults();
      _updateControllers();
    } catch (e) {
      _setError('Failed to load company profile: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save company profile
  Future<bool> saveCompanyProfile() async {
    try {
      _isSaving = true;
      _clearMessages();
      notifyListeners();

      // Create updated profile from form controllers
      final updatedProfile = CompanyProfileModel(
        companyName: companyNameController.text.trim(),
        logoPath: _companyProfile?.logoPath,
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        phoneNumber: phoneNumberController.text.trim().isEmpty
            ? null
            : phoneNumberController.text.trim(),
        telephoneNumber: telephoneNumberController.text.trim().isEmpty
            ? null
            : telephoneNumberController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        website: websiteController.text.trim().isEmpty
            ? null
            : websiteController.text.trim(),
        footerNotes: footerNotesController.text.trim().isEmpty
            ? null
            : footerNotesController.text.trim(),
        preparedBy: preparedByController.text.trim().isEmpty
            ? null
            : preparedByController.text.trim(),
      );

      await _settingsRepository.saveCompanyProfile(updatedProfile);
      _companyProfile = updatedProfile;
      _setSuccess('Company profile saved successfully');

      return true;
    } catch (e) {
      _setError('Failed to save company profile: ${e.toString()}');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Upload company logo
  Future<bool> uploadLogo(File logoFile) async {
    try {
      _isUploadingLogo = true;
      _clearMessages();
      notifyListeners();

      // In a real app, you would upload to a server or copy to app directory
      // For now, we'll just store the file path
      final logoPath = logoFile.path;

      // Update company profile with logo path
      if (_companyProfile != null) {
        final updatedProfile = _companyProfile!.copyWith(logoPath: logoPath);
        await _settingsRepository.saveCompanyProfile(updatedProfile);
        _companyProfile = updatedProfile;
      }

      _setSuccess('Logo uploaded successfully');
      return true;
    } catch (e) {
      _setError('Failed to upload logo: ${e.toString()}');
      return false;
    } finally {
      _isUploadingLogo = false;
      notifyListeners();
    }
  }

  /// Remove company logo
  Future<void> removeLogo() async {
    try {
      _clearMessages();

      if (_companyProfile != null) {
        final updatedProfile = _companyProfile!.copyWith(logoPath: null);
        await _settingsRepository.saveCompanyProfile(updatedProfile);
        _companyProfile = updatedProfile;
        _setSuccess('Logo removed successfully');
      }
    } catch (e) {
      _setError('Failed to remove logo: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  /// Reset company profile to defaults
  Future<void> resetToDefaults() async {
    try {
      _isSaving = true;
      _clearMessages();
      notifyListeners();

      await _settingsRepository.resetCompanyProfile();
      await loadCompanyProfile();
      _setSuccess('Company profile reset to defaults');
    } catch (e) {
      _setError('Failed to reset company profile: ${e.toString()}');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Update form controllers with current profile data
  void _updateControllers() {
    if (_companyProfile != null) {
      companyNameController.text = _companyProfile!.companyName;
      addressController.text = _companyProfile!.address ?? '';
      phoneNumberController.text = _companyProfile!.phoneNumber ?? '';
      telephoneNumberController.text = _companyProfile!.telephoneNumber ?? '';
      emailController.text = _companyProfile!.email ?? '';
      websiteController.text = _companyProfile!.website ?? '';
      footerNotesController.text = _companyProfile!.footerNotes ?? '';
      preparedByController.text = _companyProfile!.preparedBy ?? '';
    }
  }

  /// Validate company profile form
  String? validateForm() {
    if (companyNameController.text.trim().isEmpty) {
      return 'Company name is required';
    }

    if (companyNameController.text.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }

    // Validate email if provided
    if (emailController.text.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailController.text.trim())) {
        return 'Please enter a valid email address';
      }
    }

    // Validate website if provided
    if (websiteController.text.trim().isNotEmpty) {
      final websiteText = websiteController.text.trim();
      if (!websiteText.startsWith('http://') &&
          !websiteText.startsWith('https://')) {
        return 'Website must start with http:// or https://';
      }
    }

    return null;
  }

  /// Check if form has unsaved changes
  bool get hasUnsavedChanges {
    if (_companyProfile == null) return false;

    return companyNameController.text.trim() != _companyProfile!.companyName ||
        addressController.text.trim() != (_companyProfile!.address ?? '') ||
        phoneNumberController.text.trim() !=
            (_companyProfile!.phoneNumber ?? '') ||
        telephoneNumberController.text.trim() !=
            (_companyProfile!.telephoneNumber ?? '') ||
        emailController.text.trim() != (_companyProfile!.email ?? '') ||
        websiteController.text.trim() != (_companyProfile!.website ?? '') ||
        footerNotesController.text.trim() !=
            (_companyProfile!.footerNotes ?? '') ||
        preparedByController.text.trim() != (_companyProfile!.preparedBy ?? '');
  }

  /// Discard unsaved changes
  void discardChanges() {
    _updateControllers();
    _clearMessages();
    notifyListeners();
  }

  /// Get app information
  Map<String, String> get appInfo => {
        'appName': 'Solarize',
        'version': '1.0.0',
        'description': 'Professional Solar Quotations Made Simple',
      };

  /// Get about app text
  String get aboutAppText =>
      'Solarize is a simple yet powerful app built for solar consultants to quickly create professional quotations using customizable input presets. Whether you\'re selecting price values, dropdowns, or checkboxes, the app helps you generate clear estimates and export them as PDFs or images you can easily share via email or messaging apps.';

  /// Get about us text
  String get aboutUsText =>
      'This app was built by Hanakki, a solo developer and 3rd year Computer Engineering student from Toledo City, Cebu, studying at the University of San Carlos (USC). Originally created as a final project for CPE 3323 Mobile Applications Development, this app also serves as a small tribute to her father, who runs a solar company and inspired the idea behind making quotation estimates simpler and more efficient. Got issues or suggestions? Hit her up at solarize@gmail.com.';

  // Utility Methods

  /// Clear all messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
  }

  /// Set success message
  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
  }

  /// Clear messages (public method)
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  @override
  void dispose() {
    // Dispose controllers
    companyNameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    telephoneNumberController.dispose();
    emailController.dispose();
    websiteController.dispose();
    footerNotesController.dispose();
    preparedByController.dispose();
    super.dispose();
  }
}
