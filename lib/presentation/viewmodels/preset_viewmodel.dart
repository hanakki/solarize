import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/preset_model.dart';
import '../../data/models/project_row_model.dart';
import '../../data/repositories/preset_repository.dart';

/// ViewModel for preset management
/// Handles CRUD operations for presets and preset selection
class PresetViewModel extends ChangeNotifier {
  final PresetRepository _presetRepository;
  final Uuid _uuid = const Uuid();

  PresetViewModel(this._presetRepository);

  // State variables
  List<PresetModel> _presets = [];
  PresetModel? _currentPreset;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<PresetModel> get presets => _searchQuery.isEmpty
      ? _presets
      : _presets
          .where((preset) =>
              preset.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
  PresetModel? get currentPreset => _currentPreset;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Load all presets
  Future<void> loadPresets() async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();

      _presets = await _presetRepository.getAllPresets();
    } catch (e) {
      _setError('Failed to load presets: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a specific preset by ID
  Future<void> loadPreset(String id) async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();

      _currentPreset = await _presetRepository.getPresetById(id);
    } catch (e) {
      _setError('Failed to load preset: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new preset
  Future<bool> createPreset({
    required String name,
    String? description,
    required List<ProjectRowModel> rows,
  }) async {
    try {
      _isSaving = true;
      _clearError();
      notifyListeners();

      // Check if name already exists
      final nameExists = await _presetRepository.presetNameExists(name);
      if (nameExists) {
        _setError('A preset with this name already exists');
        return false;
      }

      // Create preset
      final preset = await _presetRepository.createPreset(
        name: name,
        description: description,
        rows: rows,
      );

      // Add to local list
      _presets.add(preset);
      _currentPreset = preset;

      return true;
    } catch (e) {
      _setError('Failed to create preset: ${e.toString()}');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Update an existing preset
  Future<bool> updatePreset({
    required String id,
    required String name,
    String? description,
    required List<ProjectRowModel> rows,
  }) async {
    try {
      _isSaving = true;
      _clearError();
      notifyListeners();

      // Find existing preset
      final existingPreset = _presets.where((p) => p.id == id).firstOrNull;
      if (existingPreset == null) {
        _setError('Preset not found');
        return false;
      }

      // Check if name already exists (excluding current preset)
      final nameExists =
          await _presetRepository.presetNameExists(name, excludeId: id);
      if (nameExists) {
        _setError('A preset with this name already exists');
        return false;
      }

      // Update preset
      final updatedPreset = existingPreset.copyWith(
        name: name,
        defaultRows: rows,
        updatedAt: DateTime.now(),
      );

      await _presetRepository.updatePreset(updatedPreset);

      // Update local list
      final index = _presets.indexWhere((p) => p.id == id);
      if (index != -1) {
        _presets[index] = updatedPreset;
      }

      _currentPreset = updatedPreset;

      return true;
    } catch (e) {
      _setError('Failed to update preset: ${e.toString()}');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Delete a preset
  Future<bool> deletePreset(String id) async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();

      await _presetRepository.deletePreset(id);

      // Remove from local list
      _presets.removeWhere((p) => p.id == id);

      // Clear current preset if it was deleted
      if (_currentPreset?.id == id) {
        _currentPreset = null;
      }

      return true;
    } catch (e) {
      _setError('Failed to delete preset: ${e.toString()}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a preset
  void selectPreset(PresetModel preset) {
    _currentPreset = preset;
    _clearError();
    notifyListeners();
  }

  /// Clear current preset selection
  void clearSelection() {
    _currentPreset = null;
    _clearError();
    notifyListeners();
  }

  /// Create a new empty preset for editing
  void createNewPreset() {
    _currentPreset = PresetModel(
      id: _uuid.v4(),
      name: '',
      defaultRows: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _clearError();
    notifyListeners();
  }

  /// Add a row to current preset
  void addRowToCurrentPreset(ProjectRowModel row) {
    if (_currentPreset != null) {
      final updatedRows = [..._currentPreset!.defaultRows, row];
      _currentPreset = _currentPreset!.copyWith(defaultRows: updatedRows);
      notifyListeners();
    }
  }

  /// Update a row in current preset
  void updateRowInCurrentPreset(int index, ProjectRowModel row) {
    if (_currentPreset != null &&
        index >= 0 &&
        index < _currentPreset!.defaultRows.length) {
      final updatedRows = [..._currentPreset!.defaultRows];
      updatedRows[index] = row;
      _currentPreset = _currentPreset!.copyWith(defaultRows: updatedRows);
      notifyListeners();
    }
  }

  /// Remove a row from current preset
  void removeRowFromCurrentPreset(int index) {
    if (_currentPreset != null &&
        index >= 0 &&
        index < _currentPreset!.defaultRows.length) {
      final updatedRows = [..._currentPreset!.defaultRows];
      updatedRows.removeAt(index);
      _currentPreset = _currentPreset!.copyWith(defaultRows: updatedRows);
      notifyListeners();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Get user-created presets only
  List<PresetModel> get userPresets =>
      _presets.where((p) => !p.isDefault).toList();

  /// Get default presets only
  List<PresetModel> get defaultPresets =>
      _presets.where((p) => p.isDefault).toList();

  /// Check if preset name is valid
  bool isPresetNameValid(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 3;
  }

  /// Validate preset data
  String? validatePreset({
    required String name,
    required List<ProjectRowModel> rows,
  }) {
    if (name.trim().isEmpty) {
      return 'Preset name is required';
    }

    if (name.trim().length < 3) {
      return 'Preset name must be at least 3 characters';
    }

    if (rows.isEmpty) {
      return 'Preset must have at least one row';
    }

    return null;
  }

  // Utility Methods

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
  }

  /// Clear error message (public method)
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Refresh presets
  Future<void> refresh() async {
    await loadPresets();
  }
}
