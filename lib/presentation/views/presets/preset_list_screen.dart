import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/preset_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/white_content_container.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../data/models/preset_model.dart';
import 'widgets/preset_item_widget.dart';
import 'preset_detail_screen.dart';

// for displaying and managing presets
class PresetListScreen extends StatefulWidget {
  const PresetListScreen({super.key});

  @override
  State<PresetListScreen> createState() => _PresetListScreenState();
}

class _PresetListScreenState extends State<PresetListScreen> {
  @override
  void initState() {
    super.initState();
    // Load presets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PresetViewModel>().loadPresets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Consumer<PresetViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    CustomAppBar(
                      title: 'Load Preset',
                      onBackPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: WhiteContentContainer(
                        topMargin: 0,
                        child: _buildContent(viewModel),
                      ),
                    ),
                  ],
                ),
                if (viewModel.isLoading) const LoadingOverlay(),
              ],
            );
          },
        ),
      ),

      // action button for adding new preset
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: FloatingActionButton(
          onPressed: () => _addNewPreset(),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PresetViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return _buildErrorState(viewModel);
    }

    if (viewModel.presets.isEmpty && !viewModel.isLoading) {
      return _buildEmptyState();
    }

    return _buildPresetList(viewModel);
  }

  Widget _buildErrorState(PresetViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading presets',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => viewModel.loadPresets(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No presets yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first preset to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addNewPreset(),
            icon: const Icon(Icons.add),
            label: const Text('Create Preset'),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetList(PresetViewModel viewModel) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: viewModel.presets.length,
      itemBuilder: (context, index) {
        final preset = viewModel.presets[index];
        return PresetItemWidget(
          preset: preset,
          onTap: () => _selectPreset(preset),
          onEdit: () => _editPreset(preset),
          onDelete: () => _deletePreset(preset),
        );
      },
    );
  }

  void _addNewPreset() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PresetDetailScreen(),
      ),
    );

    if (result == true && mounted) {
      // Refresh the list if a preset was created
      context.read<PresetViewModel>().loadPresets();
    }
  }

  void _selectPreset(PresetModel preset) {
    // Return the preset's rows to the previous screen
    print(
        'Selected preset: ${preset.name} with ${preset.defaultRows.length} rows');
    Navigator.pop(context, preset.defaultRows);
  }

  void _editPreset(PresetModel preset) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PresetDetailScreen(preset: preset),
      ),
    );

    if (result == true && mounted) {
      // Refresh the list if a preset was updated
      context.read<PresetViewModel>().loadPresets();
    }
  }

  void _deletePreset(PresetModel preset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text(
          'Are you sure you want to delete "${preset.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final viewModel = context.read<PresetViewModel>();
              final success = await viewModel.deletePreset(preset.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preset deleted successfully'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
