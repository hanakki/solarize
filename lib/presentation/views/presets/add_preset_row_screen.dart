import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/white_content_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/project_row_model.dart';
import '../../../core/utils/validators.dart';

/// Screen for adding or editing preset rows/particulars
class AddPresetRowScreen extends StatefulWidget {
  final ProjectRowModel? existingRow;

  const AddPresetRowScreen({
    super.key,
    this.existingRow,
  });

  @override
  State<AddPresetRowScreen> createState() => _AddPresetRowScreenState();
}

class _AddPresetRowScreenState extends State<AddPresetRowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final Uuid _uuid = const Uuid();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.existingRow != null) {
      _isEditing = true;
      final row = widget.existingRow!;
      _titleController.text = row.title;
      _quantityController.text = row.quantity.toString();
      _unitController.text = row.unit;
      _descriptionController.text = row.description;
      _priceController.text = row.estimatedPrice.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          children: [
            // Custom app bar
            CustomAppBar(
              title: _isEditing ? 'Edit Particular' : 'Add Particular',
              onBackPressed: () => Navigator.pop(context),
            ),

            // Content
            Expanded(
              child: WhiteContentContainer(
                topMargin: 0,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
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
                  // Title of particular
                  CustomTextField(
                    label: 'Title of Particular',
                    controller: _titleController,
                    validator: Validators.validateProjectName,
                  ),

                  const SizedBox(height: 16),

                  // Quantity
                  CustomTextField(
                    label: 'Quantity',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quantity is required';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Quantity must be a positive number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Unit
                  CustomTextField(
                    label: 'Unit',
                    controller: _unitController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unit is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Estimated Price
                  CustomTextField(
                    label: 'Estimated Price',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Estimated price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 0) {
                        return 'Price must be a valid number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Save',
                      onPressed: _canSave() ? _saveRow : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty &&
        _quantityController.text.trim().isNotEmpty &&
        _unitController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty;
  }

  void _saveRow() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final row = ProjectRowModel(
      id: widget.existingRow?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      unit: _unitController.text.trim(),
      description: _descriptionController.text.trim(),
      estimatedPrice: double.parse(_priceController.text.trim()),
      isAutoGenerated: false,
    );

    Navigator.pop(context, row);
  }
}
