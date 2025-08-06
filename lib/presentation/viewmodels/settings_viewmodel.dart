import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/company_profile_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/services/image_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  SettingsViewModel(this._settingsRepository);

  CompanyProfileModel? _companyProfile;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  String? _errorMessage;
  String? _successMessage;

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController telephoneNumberController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController footerNotesController = TextEditingController();
  final TextEditingController preparedByController = TextEditingController();

  CompanyProfileModel? get companyProfile => _companyProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingLogo => _isUploadingLogo;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasLogo => _companyProfile?.hasLogo ?? false;
  String? get logoPath => _companyProfile?.logoPath;

  Future<void> initialize() async {
    await loadCompanyProfile();
  }

  Future<void> loadCompanyProfile() async {
    try {
      _isLoading = true;
      _clearMessages();
      notifyListeners();
      _companyProfile =
          await _settingsRepository.getCompanyProfileWithDefaults();
      if (_companyProfile?.hasLogo == true) {
        final logoExists =
            await ImageService.logoExists(_companyProfile!.logoPath);
        if (!logoExists) {
          final updatedProfile = _companyProfile!.copyWith(logoPath: null);
          await _settingsRepository.saveCompanyProfile(updatedProfile);
          _companyProfile = updatedProfile;
        }
      }

      _updateControllers();
    } catch (e) {
      _setError('Failed to load company profile: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveCompanyProfile() async {
    try {
      _isSaving = true;
      _clearMessages();
      notifyListeners();

      final validationError = validateForm();
      if (validationError != null) {
        _setError(validationError);
        return false;
      }

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

      await loadCompanyProfile();

      return true;
    } catch (e) {
      _setError('Failed to save company profile: ${e.toString()}');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> uploadLogo(File logoFile) async {
    try {
      _isUploadingLogo = true;
      _clearMessages();
      notifyListeners();

      if (!await ImageService.logoExists(logoFile.path)) {
        throw Exception('Selected file does not exist');
      }

      final fileSize = await logoFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('File size must be less than 5MB');
      }

      final logoPath = await ImageService.copyLogoToAppDirectory(logoFile.path);

      if (_companyProfile != null) {
        final updatedProfile = _companyProfile!.copyWith(logoPath: logoPath);
        await _settingsRepository.saveCompanyProfile(updatedProfile);
        _companyProfile = updatedProfile;

        await loadCompanyProfile();

        return true;
      } else {
        throw Exception('Company profile not loaded');
      }
    } catch (e) {
      _setError('Failed to upload logo: ${e.toString()}');
      return false;
    } finally {
      _isUploadingLogo = false;
      notifyListeners();
    }
  }

  Future<void> removeLogo() async {
    try {
      _clearMessages();

      if (_companyProfile != null) {
        if (_companyProfile!.logoPath != null) {
          await ImageService.deleteLogo(_companyProfile!.logoPath);
        }

        final updatedProfile = _companyProfile!.copyWith(logoPath: null);
        await _settingsRepository.saveCompanyProfile(updatedProfile);
        _companyProfile = updatedProfile;

        await loadCompanyProfile();
      }
    } catch (e) {
      _setError('Failed to remove logo: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

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

  String? validateForm() {
    if (companyNameController.text.trim().isEmpty) {
      return 'Company name is required';
    }

    if (companyNameController.text.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }

    if (emailController.text.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailController.text.trim())) {
        return 'Please enter a valid email address';
      }
    }

    if (websiteController.text.trim().isNotEmpty) {
      final websiteText = websiteController.text.trim();
      if (!websiteText.startsWith('http://') &&
          !websiteText.startsWith('https://')) {
        return 'Website must start with http:// or https://';
      }
    }

    return null;
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
  }

  @override
  void dispose() {
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
