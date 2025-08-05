import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/preset_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/white_content_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../data/models/preset_model.dart';
import '../../../data/models/project_row_model.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/typography.dart';
import 'add_preset_row_screen.dart';

/// Screen for creating or editing presets
class PresetDetailScreen extends StatefulWidget {
  final PresetModel? preset;

  const PresetDetailScreen({
    super.key,
    this.preset,
  });

  @override
  State<PresetDetailScreen> createState() => _PresetDetailScreenState();
}

class _PresetDetailScreenState extends State<PresetDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<ProjectRowModel> _rows = [];
  bool _isEditing = false;

  // Track expanded state for each accordion
  final Map<int, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.preset != null) {
      _isEditing = true;
      _titleController.text = widget.preset!.name;
      _rows = List.from(widget.preset!.defaultRows);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                      title: _isEditing ? 'Edit Preset' : 'Create Preset',
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
                if (viewModel.isSaving) const LoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(PresetViewModel viewModel) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: AppStrings.presetTitleLabel,
                    controller: _titleController,
                    validator: Validators.validateProjectName,
                    hint: 'Enter preset title',
                  ),
                  const SizedBox(height: 24),
                  _buildParticularsSection(),
                  _buildAddRowButton(),
                  const SizedBox(height: 32),
                  _buildSaveButton(viewModel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticularsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_rows.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No items added yet.\nTap "Add Row" to get started.',
                textAlign: TextAlign.center,
                style: AppTypography.interRegularGray16_24_00,
              ),
            ),
          )
        else
          ...List.generate(_rows.length, (index) {
            final row = _rows[index];
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
          onLongPress: () => _showRowOptions(index),
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
              ? SizedBox(
                  width: double.infinity,
                  child: content,
                )
              : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

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

  Widget _buildSaveButton(PresetViewModel viewModel) {
    return CustomButton(
      text: AppStrings.saveButton,
      onPressed: _canSave() ? () => _savePreset(viewModel) : null,
    );
  }

  double _calculateTotal() {
    return _rows.fold(0.0, (sum, row) => sum + row.totalPrice);
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty && _rows.isNotEmpty;
  }

  void _addRow() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPresetRowScreen(),
      ),
    );

    if (result is ProjectRowModel) {
      setState(() {
        _rows.add(result);
      });
    }
  }

  void _showRowOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editRow(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
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

  void _editRow(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPresetRowScreen(existingRow: _rows[index]),
      ),
    );

    if (result is ProjectRowModel) {
      setState(() {
        _rows[index] = result;
      });
    }
  }

  void _deleteRow(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Particular'),
        content: const Text('Are you sure you want to delete this particular?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _rows.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _savePreset(PresetViewModel viewModel) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = _isEditing
        ? await viewModel.updatePreset(
            id: widget.preset!.id,
            name: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            rows: _rows,
          )
        : await viewModel.createPreset(
            name: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            rows: _rows,
          );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Preset updated successfully'
                : 'Preset created successfully',
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }
}
