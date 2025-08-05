import 'package:flutter/material.dart';
import '../../data/models/preset_model.dart';
import '../../data/models/project_row_model.dart';
import '../../data/repositories/preset_repository.dart';

class PresetViewModel extends ChangeNotifier {
  final PresetRepository _presetRepository;

  PresetViewModel(this._presetRepository);

  List<PresetModel> _presets = [];
  PresetModel? _currentPreset;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';

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

  Future<bool> createPreset({
    required String name,
    String? description,
    required List<ProjectRowModel> rows,
  }) async {
    try {
      _isSaving = true;
      _clearError();
      notifyListeners();

      final nameExists = await _presetRepository.presetNameExists(name);
      if (nameExists) {
        _setError('A preset with this name already exists');
        return false;
      }

      final preset = await _presetRepository.createPreset(
        name: name,
        description: description,
        rows: rows,
      );

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

      final existingPreset = _presets.where((p) => p.id == id).firstOrNull;
      if (existingPreset == null) {
        _setError('Preset not found');
        return false;
      }

      final nameExists =
          await _presetRepository.presetNameExists(name, excludeId: id);
      if (nameExists) {
        _setError('A preset with this name already exists');
        return false;
      }

      final updatedPreset = existingPreset.copyWith(
        name: name,
        defaultRows: rows,
        updatedAt: DateTime.now(),
      );

      await _presetRepository.updatePreset(updatedPreset);

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

  Future<bool> deletePreset(String id) async {
    try {
      _isLoading = true;
      _clearError();
      notifyListeners();

      await _presetRepository.deletePreset(id);

      _presets.removeWhere((p) => p.id == id);

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

  void selectPreset(PresetModel preset) {
    _currentPreset = preset;
    _clearError();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  List<PresetModel> get userPresets =>
      _presets.where((p) => !p.isDefault).toList();

  List<PresetModel> get defaultPresets =>
      _presets.where((p) => p.isDefault).toList();

  bool isPresetNameValid(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 3;
  }

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

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  Future<void> refresh() async {
    await loadPresets();
  }
}
