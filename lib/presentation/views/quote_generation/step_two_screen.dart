import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../viewmodels/preset_viewmodel.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/accordion_widget.dart';
import 'widgets/step_header_widget.dart';
import '../../../data/models/project_details_model.dart';
import '../../../data/models/project_row_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/strings.dart';
import '../presets/preset_list_screen.dart';
import '../../../core/constants/typography.dart';

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

  // Track expanded state for each accordion
  final Map<int, bool> _expandedStates = {};

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
                      _buildLoadPresetSection(),
                      const SizedBox(height: 24),
                      _buildProjectInfoSection(),
                      const SizedBox(height: 24),
                      _buildItemizedListSection(),
                      const SizedBox(height: 24),
                      _buildAddRowButton(),
                      const SizedBox(height: 45),
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

  /// Build load preset section
  Widget _buildLoadPresetSection() {
    return CustomButton(
      text: AppStrings.loadPresetButton,
      style: CustomButtonStyle.secondary,
      onPressed: _navigateToLoadPreset,
    );
  }

  /// Build project information section (no container)
  Widget _buildProjectInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: AppStrings.projectNameLabel,
          controller: _projectNameController,
          validator: Validators.validateProjectName,
          hint: 'Toledo City Gym',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: AppStrings.clientNameLabel,
          controller: _clientNameController,
          validator: Validators.validateClientName,
          hint: 'Juan Dela Cruz',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: AppStrings.projectLocationLabel,
          controller: _locationController,
          validator: Validators.validateLocation,
          maxLines: 2,
          hint: 'Toledo City',
        ),
      ],
    );
  }

  Widget _buildItemizedListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project rows as accordions
        if (_projectRows.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No items added yet.\nTap "Add Row" to get started.',
                textAlign: TextAlign.center,
                style: AppTypography.interRegularGray16_24_00,
              ),
            ),
          )
        else
          ...List.generate(_projectRows.length, (index) {
            final row = _projectRows[index];
            return _buildItemAccordion(row, index);
          }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
      ],
    );
  }

  /// Build item accordion
  Widget _buildItemAccordion(ProjectRowModel row, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0, 8),
          child: Text(
            'ROW ${index + 1}',
            style: AppTypography.interSemiBoldGray12_16_15,
          ),
        ),
        const SizedBox(height: 8),
        _buildCustomAccordion(
          title: row.title,
          subtitle: '₱${row.totalPrice.toStringAsFixed(2)}',
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                _buildDetailRow('Quantity', '${row.quantity}'),
                _buildDetailRow('Unit', row.unit),
                _buildDetailRow('Description', 'Model: ${row.title}'),
                _buildDetailRow('Estimated Price',
                    '₱${row.estimatedPrice.toStringAsFixed(2)}'),
              ],
            ),
          ),
          onLongPress: () => _showEditDeleteOptions(index),
          index: index,
        ),
      ],
    );
  }

  /// Build custom accordion widget
  Widget _buildCustomAccordion({
    required String title,
    required String subtitle,
    required Widget content,
    required VoidCallback onLongPress,
    required int index,
  }) {
    final isExpanded = _expandedStates[index] ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedStates[index] = !isExpanded;
            });
          },
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.interSemiBoldBlack18_24_0,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        _buildDivider(),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isExpanded ? null : 0,
          child: isExpanded
              ? Container(
                  width: double.infinity,
                  child: content,
                )
              : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Build detail row for accordion content
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.interSemiBoldBlack16_24_0,
          ),
          Text(
            value,
            style: AppTypography.interRegularGray16_24_00,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFA4A3B3),
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildAddRowButton() {
    return CustomButton(
      text: AppStrings.addRowButton,
      style: CustomButtonStyle.tertiary,
      onPressed: _addRow,
      icon: const Icon(Icons.add),
    );
  }

  /// Build navigation buttons (column layout)
  Widget _buildNavigationButtons(QuoteGenerationViewModel viewModel) {
    return Column(
      children: [
        // Proceed Button (Primary)
        CustomButton(
          text: AppStrings.proceedButton,
          onPressed: _canProceed() ? () => _handleProceed(viewModel) : null,
        ),
        const SizedBox(height: 16),
        // Back Button (Secondary)
        CustomButton(
          text: AppStrings.backButton,
          style: CustomButtonStyle.secondary,
          onPressed: viewModel.previousStep,
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

  /// Navigate to load preset screen
  void _navigateToLoadPreset() async {
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

  /// Show edit/delete options on long press
  void _showEditDeleteOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Item'),
              onTap: () {
                Navigator.pop(context);
                _editRow(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Item',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteRow(index);
              },
            ),
          ],
        ),
      ),
    );
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
}
