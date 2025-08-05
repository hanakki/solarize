import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/preset_model.dart';
import '../../data/models/company_profile_model.dart';

/// Service class for handling local storage operations
/// Uses SharedPreferences to store app data locally
class LocalStorageService {
  static SharedPreferences? _prefs;

  /// Initialize the local storage service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
          'LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Quote Operations

  /// Save a quote to local storage
  Future<void> saveQuote(QuoteModel quote) async {
    try {
      final quotes = await getQuotes();
      final existingIndex = quotes.indexWhere((q) => q.id == quote.id);

      if (existingIndex != -1) {
        quotes[existingIndex] = quote;
      } else {
        quotes.add(quote);
      }

      final quotesJson = quotes.map((q) => q.toJson()).toList();
      await prefs.setString(
          AppConstants.quotesStorageKey, jsonEncode(quotesJson));
    } catch (e) {
      throw Exception('Failed to save quote: $e');
    }
  }

  /// Get all quotes from local storage
  Future<List<QuoteModel>> getQuotes() async {
    try {
      final quotesString = prefs.getString(AppConstants.quotesStorageKey);
      if (quotesString == null) return [];

      final quotesJson = jsonDecode(quotesString) as List;
      return quotesJson.map((json) => QuoteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load quotes: $e');
    }
  }

  /// Delete a quote from local storage
  Future<void> deleteQuote(String quoteId) async {
    try {
      final quotes = await getQuotes();
      quotes.removeWhere((q) => q.id == quoteId);

      final quotesJson = quotes.map((q) => q.toJson()).toList();
      await prefs.setString(
          AppConstants.quotesStorageKey, jsonEncode(quotesJson));
    } catch (e) {
      throw Exception('Failed to delete quote: $e');
    }
  }

  // Preset Operations

  /// Save a preset to local storage
  Future<void> savePreset(PresetModel preset) async {
    try {
      final presets = await getPresets();
      final existingIndex = presets.indexWhere((p) => p.id == preset.id);

      if (existingIndex != -1) {
        presets[existingIndex] = preset;
      } else {
        presets.add(preset);
      }

      final presetsJson = presets.map((p) => p.toJson()).toList();
      await prefs.setString(
          AppConstants.presetsStorageKey, jsonEncode(presetsJson));
    } catch (e) {
      throw Exception('Failed to save preset: $e');
    }
  }

  /// Get all presets from local storage
  Future<List<PresetModel>> getPresets() async {
    try {
      final presetsString = prefs.getString(AppConstants.presetsStorageKey);
      if (presetsString == null) return [];

      final presetsJson = jsonDecode(presetsString) as List;
      return presetsJson.map((json) => PresetModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load presets: $e');
    }
  }

  /// Delete a preset from local storage
  Future<void> deletePreset(String presetId) async {
    try {
      final presets = await getPresets();
      presets.removeWhere((p) => p.id == presetId);

      final presetsJson = presets.map((p) => p.toJson()).toList();
      await prefs.setString(
          AppConstants.presetsStorageKey, jsonEncode(presetsJson));
    } catch (e) {
      throw Exception('Failed to delete preset: $e');
    }
  }

  /// Clear all presets from local storage
  Future<void> clearPresets() async {
    try {
      await prefs.remove(AppConstants.presetsStorageKey);
    } catch (e) {
      throw Exception('Failed to clear presets: $e');
    }
  }

  // Settings Operations

  /// Save company profile settings
  Future<void> saveSettings(CompanyProfileModel settings) async {
    try {
      await prefs.setString(
          AppConstants.settingsStorageKey, jsonEncode(settings.toJson()));
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  /// Get company profile settings
  Future<CompanyProfileModel?> getSettings() async {
    try {
      final settingsString = prefs.getString(AppConstants.settingsStorageKey);
      if (settingsString == null) return null;

      final settingsJson = jsonDecode(settingsString);
      return CompanyProfileModel.fromJson(settingsJson);
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }
}
