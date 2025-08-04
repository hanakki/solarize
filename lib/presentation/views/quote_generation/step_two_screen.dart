import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../viewmodels/preset_viewmodel.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/accordion_widget.dart';
import 'widgets/step_header_widget.dart';
import 'widgets/project_row_widget.dart';
import '../../../data/models/project_details_model.dart';
import '../../../data/models/project_row_model.dart';
import '../../../data/models/preset_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/strings.dart';
import '../presets/preset_list_screen.dart';

/// Step 2: Enter Project Details
/// Collects project information and itemized list
class StepTwoScreen extends StatefulWidget {
  const StepTwoScreen({super.key});

  @override
  State<StepTwoScreen> createState() => _StepTwoScreenState();
}

class _StepTwoScreenState extends State<StepTwoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _locationController = TextEditingController();

  List<ProjectRowModel> _projectRows = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadPresets();
  }

  void _initializeData() {
    final viewModel = context.read<QuoteGenerationViewModel>();

    // Initialize with existing project details or defaults
    if (viewModel.projectDetails != null) {
      final details = viewModel.projectDetails!;
      _projectNameController.text = details.projectName;
      _clientNameController.text = details.clientName;
      _locationController.text = details.location;
      _projectRows = List.from(details.rows);
    } else {
      // Add default rows based on calculation results
      _projectRows = viewModel.getDefaultRows();
    }
  }

  void _loadPresets() {
    // Load presets using PresetViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presetViewModel = context.read<PresetViewModel>();
      presetViewModel.loadPresets();
    });
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _clientNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteGenerationViewModel>(
      builder: (context, viewModel, child) {
        final stepInfo = viewModel.getStepInfo(2);

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Step header
              StepHeaderWidget(
                title: stepInfo.title,
                description: stepInfo.description,
              ),

              const SizedBox(height: 24),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Project information section
                      _buildProjectInfoSection(),

                      const SizedBox(height: 24),

                      // Itemized list section
                      _buildItemizedListSection(),

                      const SizedBox(height: 24),

                      // Action buttons
                      _buildActionButtons(viewModel),

                      const SizedBox(height: 32),

                      // Navigation buttons
                      _buildNavigationButtons(viewModel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build project information section
  Widget _buildProjectInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppStrings.projectNameLabel,
              controller: _projectNameController,
              validator: Validators.validateProjectName,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppStrings.clientNameLabel,
              controller: _clientNameController,
              validator: Validators.validateClientName,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppStrings.projectLocationLabel,
              controller: _locationController,
              validator: Validators.validateLocation,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Build itemized list section
  Widget _buildItemizedListSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Itemized List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Total: ₱${_calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Project rows
            if (_projectRows.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No items added yet.\nTap "Add Row" to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_projectRows.length, (index) {
                final row = _projectRows[index];
                return ProjectRowWidget(
                  row: row,
                  onEdit: () => _editRow(index),
                  onDelete: () => _deleteRow(index),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Build action buttons section
  Widget _buildActionButtons(QuoteGenerationViewModel viewModel) {
    return Column(
      children: [
        // Add Row button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: AppStrings.addRowButton,
            style: CustomButtonStyle.secondary,
            onPressed: _addRow,
            icon: const Icon(Icons.add),
          ),
        ),

        const SizedBox(height: 16),

        // Load Preset section
        _buildLoadPresetSection(),
      ],
    );
  }

  /// Build load preset section
  Widget _buildLoadPresetSection() {
    return Consumer<PresetViewModel>(
      builder: (context, presetViewModel, child) {
        return AccordionWidget(
          title: 'Load Preset',
          subtitle: 'Select a preset to load predefined items',
          trailing: const Icon(Icons.chevron_right),
          content: Column(
            children: [
              // Show loading state
              if (presetViewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (presetViewModel.presets.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No presets available.\nCreate a preset first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                // Show preset list
                Column(
                  children: [
                    // Quick preset selection
                    ...presetViewModel.presets.take(3).map(
                          (preset) => ListTile(
                            leading: const Icon(Icons.folder),
                            title: Text(preset.name),
                            subtitle: preset.description?.isNotEmpty == true
                                ? Text(preset.description!)
                                : null,
                            trailing:
                                Text('${preset.defaultRows.length} items'),
                            onTap: () => _loadPresetFromViewModel(preset),
                          ),
                        ),
                    const SizedBox(height: 16),
                    // Browse all presets button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Browse All Presets',
                        style: CustomButtonStyle.tertiary,
                        onPressed: _browseAllPresets,
                        icon: const Icon(Icons.folder_open),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Save as preset button
                    if (_projectRows.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Save as Preset',
                          style: CustomButtonStyle.secondary,
                          onPressed: _saveAsPreset,
                          icon: const Icon(Icons.save),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build navigation buttons
  Widget _buildNavigationButtons(QuoteGenerationViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: AppStrings.backButton,
            style: CustomButtonStyle.secondary,
            onPressed: viewModel.previousStep,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: AppStrings.proceedButton,
            onPressed: _canProceed() ? () => _handleProceed(viewModel) : null,
          ),
        ),
      ],
    );
  }

  /// Calculate total price of all rows
  double _calculateTotal() {
    return _projectRows.fold(0.0, (sum, row) => sum + row.totalPrice);
  }

  /// Check if can proceed to next step
  bool _canProceed() {
    return _projectNameController.text.trim().isNotEmpty &&
        _clientNameController.text.trim().isNotEmpty &&
        _locationController.text.trim().isNotEmpty &&
        _projectRows.isNotEmpty;
  }

  /// Handle proceed to next step
  void _handleProceed(QuoteGenerationViewModel viewModel) {
    if (_formKey.currentState?.validate() ?? false) {
      final projectDetails = ProjectDetailsModel(
        projectName: _projectNameController.text.trim(),
        clientName: _clientNameController.text.trim(),
        location: _locationController.text.trim(),
        installationDate:
            DateTime.now().toString().split(' ')[0], // Today's date as string
        rows: _projectRows,
      );

      viewModel.updateProjectDetails(projectDetails);
      viewModel.nextStep();
    }
  }

  /// Add new row
  void _addRow() async {
    final result = await Navigator.pushNamed(
      context,
      '/add-row',
      arguments: {'isEditing': false},
    );

    if (result is ProjectRowModel) {
      setState(() {
        _projectRows.add(result);
      });
    }
  }

  /// Edit existing row
  void _editRow(int index) async {
    final result = await Navigator.pushNamed(
      context,
      '/add-row',
      arguments: {
        'existingRow': _projectRows[index],
        'isEditing': true,
      },
    );

    if (result is ProjectRowModel) {
      setState(() {
        _projectRows[index] = result;
      });
    }
  }

  /// Delete row
  void _deleteRow(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _projectRows.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Load preset from PresetViewModel
  void _loadPresetFromViewModel(PresetModel preset) {
    setState(() {
      _projectRows.addAll(preset.defaultRows);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded preset: ${preset.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Browse all presets
  void _browseAllPresets() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PresetListScreen(),
      ),
    );

    if (result is List<ProjectRowModel>) {
      setState(() {
        _projectRows.addAll(result);
      });
    }
  }

  /// Save current project rows as a preset
  void _saveAsPreset() async {
    final presetViewModel = context.read<PresetViewModel>();

    // Show dialog to get preset name
    final presetName = await _showPresetNameDialog();
    if (presetName == null || presetName.trim().isEmpty) return;

    // Create preset using PresetViewModel
    final success = await presetViewModel.createPreset(
      name: presetName.trim(),
      description: 'Project: ${_projectNameController.text.trim()}',
      rows: _projectRows,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preset "$presetName" saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(presetViewModel.errorMessage ?? 'Failed to save preset'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show dialog to get preset name
  Future<String?> _showPresetNameDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a name for this preset:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Preset Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
