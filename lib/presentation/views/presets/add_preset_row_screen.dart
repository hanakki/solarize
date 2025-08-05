import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/white_content_container.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/project_row_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/strings.dart';

// for adding or editing preset rows/particulars
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

    // listeners to trigger validation on text changes
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
              title: _isEditing ? 'Edit Particular' : 'Add Particular',
              onBackPressed: () => Navigator.pop(context),
            ),
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
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: AppStrings.addParticularLabel,
                    controller: _titleController,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Title'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: AppStrings.addQuantityLabel,
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          validator: Validators.validateQuantity,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: AppStrings.addUnitLabel,
                          controller: _unitController,
                          validator: (value) =>
                              Validators.validateRequired(value, 'Unit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: AppStrings.addDescriptionLabel,
                    controller: _descriptionController,
                    maxLines: 3,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Description'),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: AppStrings.addEstimatedPriceLabel,
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePrice,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                        text: AppStrings.saveButton,
                        onPressed: _canSave() ? _saveRow : null,
                        style: CustomButtonStyle.primary),
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

    return titleValid &&
        quantityValid &&
        unitValid &&
        descriptionValid &&
        priceValid;
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
