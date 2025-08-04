import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/white_content_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/project_row_model.dart';
import '../../../core/utils/validators.dart';

/// Screen for adding or editing project rows
/// Allows users to input quantity, unit, description, and price
class AddRowScreen extends StatefulWidget {
  final ProjectRowModel? existingRow;
  final bool isEditing;

  const AddRowScreen({
    super.key,
    this.existingRow,
    this.isEditing = false,
  });

  @override
  State<AddRowScreen> createState() => _AddRowScreenState();
}

class _AddRowScreenState extends State<AddRowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Add listeners to trigger validation on text changes
    _titleController.addListener(_onFieldChanged);
    _quantityController.addListener(_onFieldChanged);
    _unitController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    // Trigger form validation when fields change
    if (mounted) {
      setState(() {});
    }
  }

  void _initializeControllers() {
    if (widget.existingRow != null) {
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
    _titleController.removeListener(_onFieldChanged);
    _quantityController.removeListener(_onFieldChanged);
    _unitController.removeListener(_onFieldChanged);
    _descriptionController.removeListener(_onFieldChanged);
    _priceController.removeListener(_onFieldChanged);

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
            CustomAppBar(
              title: widget.isEditing ? 'Edit Item' : 'Add Item',
            ),
            Expanded(
              child: WhiteContentContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header
                      Text(
                        widget.isEditing ? 'Edit Item Details' : 'Add New Item',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Enter the details for this quotation item',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Form fields
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Title
                              CustomTextField(
                                label: 'Title of Particular',
                                controller: _titleController,
                                hint: 'Enter particular title',
                                validator: (value) =>
                                    Validators.validateRequired(value, 'Title'),
                              ),

                              const SizedBox(height: 24),

                              // Quantity and Unit row
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: CustomTextField(
                                      label: 'Quantity',
                                      controller: _quantityController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: Validators.validateQuantity,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: CustomTextField(
                                      label: 'Unit',
                                      controller: _unitController,
                                      hint: 'e.g., pcs, lot, meter',
                                      validator: (value) =>
                                          Validators.validateRequired(
                                              value, 'Unit'),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Description
                              CustomTextField(
                                label: 'Description',
                                controller: _descriptionController,
                                hint: 'Enter item description',
                                maxLines: 3,
                                validator: (value) =>
                                    Validators.validateRequired(
                                        value, 'Description'),
                              ),

                              const SizedBox(height: 24),

                              // Price
                              CustomTextField(
                                label: 'Unit Price (₱)',
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*')),
                                ],
                                validator: Validators.validatePrice,
                                prefixIcon: const Icon(Icons.attach_money),
                              ),

                              const SizedBox(height: 32),

                              // Total price display
                              _buildTotalPriceDisplay(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Cancel',
                              style: CustomButtonStyle.secondary,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text:
                                  widget.isEditing ? 'Update Item' : 'Add Item',
                              onPressed: _isFormValid() ? _saveRow : null,
                              style: _isFormValid()
                                  ? CustomButtonStyle.primary
                                  : CustomButtonStyle.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build total price display
  Widget _buildTotalPriceDisplay() {
    return ValueListenableBuilder(
      valueListenable: _quantityController,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: _priceController,
          builder: (context, value, child) {
            final quantity = int.tryParse(_quantityController.text) ?? 0;
            final price = double.tryParse(_priceController.text) ?? 0;
            final total = quantity * price;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₱${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Check if form is valid
  bool _isFormValid() {
    final titleValid =
        Validators.validateRequired(_titleController.text.trim(), 'Title') ==
            null;
    final quantityValid =
        Validators.validateQuantity(_quantityController.text) == null;
    final unitValid =
        Validators.validateRequired(_unitController.text.trim(), 'Unit') ==
            null;
    final descriptionValid = Validators.validateRequired(
            _descriptionController.text.trim(), 'Description') ==
        null;
    final priceValid = Validators.validatePrice(_priceController.text) == null;

    final isValid = titleValid &&
        quantityValid &&
        unitValid &&
        descriptionValid &&
        priceValid;

    return isValid;
  }

  /// Save the row and return to previous screen
  void _saveRow() {
    // Validate form and get validation result
    final isValid = _formKey.currentState?.validate() ?? false;

    if (isValid) {
      final row = ProjectRowModel(
        id: widget.existingRow?.id ?? _uuid.v4(),
        title: _titleController.text.trim(),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text.trim(),
        description: _descriptionController.text.trim(),
        estimatedPrice: double.parse(_priceController.text),
        isAutoGenerated: widget.existingRow?.isAutoGenerated ?? false,
        category: widget.existingRow?.category,
      );

      Navigator.pop(context, row);
    } else {
      // Show a snackbar to indicate validation failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
