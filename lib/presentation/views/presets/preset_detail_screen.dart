import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../viewmodels/preset_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/white_content_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/accordion_widget.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../data/models/preset_model.dart';
import '../../../data/models/project_row_model.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/validators.dart';
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
  final Uuid _uuid = const Uuid();

  List<ProjectRowModel> _rows = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.preset != null) {
      _isEditing = true;
      _titleController.text = widget.preset!.name;
      _descriptionController.text = widget.preset!.description ?? '';
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
                    // Custom app bar
                    CustomAppBar(
                      title: _isEditing ? 'Edit Preset' : 'Create Preset',
                      onBackPressed: () => Navigator.pop(context),
                    ),

                    // Content
                    Expanded(
                      child: WhiteContentContainer(
                        topMargin: 0,
                        child: _buildContent(viewModel),
                      ),
                    ),
                  ],
                ),

                // Loading overlay
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  CustomTextField(
                    label: 'Preset Title',
                    controller: _titleController,
                    validator: Validators.validateProjectName,
                    hint: 'Enter preset title',
                  ),

                  const SizedBox(height: 16),

                  // Description field
                  CustomTextField(
                    label: 'Description (Optional)',
                    controller: _descriptionController,
                    maxLines: 3,
                    hint: 'Enter description',
                  ),

                  const SizedBox(height: 24),

                  // Particulars section
                  _buildParticularsSection(),

                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(viewModel),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Particulars',
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

        // Particulars list
        if (_rows.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No particulars added yet.\nTap "Add Row" to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ...List.generate(_rows.length, (index) {
            final row = _rows[index];
            return AccordionWidget(
              title: 'Row ${index + 1}',
              subtitle: row.description,
              content: _buildRowContent(row),
              onLongPress: () => _showRowOptions(index),
            );
          }),
      ],
    );
  }

  Widget _buildRowContent(ProjectRowModel row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRowDetail('Particular Name', row.title),
        _buildRowDetail('Quantity', row.quantity.toString()),
        _buildRowDetail('Unit', row.unit),
        _buildRowDetail('Description', row.description),
        _buildRowDetail(
            'Estimated Price', '₱${row.estimatedPrice.toStringAsFixed(2)}'),
        _buildRowDetail('Total Price', '₱${row.totalPrice.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildRowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PresetViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Add Row',
            style: CustomButtonStyle.tertiary,
            onPressed: _addRow,
            icon: const Icon(Icons.add),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Save',
            onPressed: _canSave() ? () => _savePreset(viewModel) : null,
          ),
        ),
      ],
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
