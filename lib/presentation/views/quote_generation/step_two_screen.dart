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
import '../../../core/utils/validators.dart';
import '../../../core/constants/strings.dart';

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
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: AppStrings.addRowButton,
            style: CustomButtonStyle.secondary,
            onPressed: _addRow,
            icon: const Icon(Icons.add),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: AppStrings.loadPresetButton,
            style: CustomButtonStyle.tertiary,
            onPressed: _loadPreset,
            icon: const Icon(Icons.download),
          ),
        ),
      ],
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

  /// Load preset
  void _loadPreset() async {
    final result = await Navigator.pushNamed(context, '/presets');

    if (result is List<ProjectRowModel>) {
      setState(() {
        _projectRows.addAll(result);
      });
    }
  }
}
