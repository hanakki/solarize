import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_checkbox.dart';
import '../../widgets/common/custom_button.dart';
import 'widgets/step_header_widget.dart';
import 'widgets/slider_input_widget.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/typography.dart';

/// Step 1: Calculate System Size
/// Collects user inputs for solar system calculations
class StepOneScreen extends StatefulWidget {
  const StepOneScreen({super.key});

  @override
  State<StepOneScreen> createState() => _StepOneScreenState();
}

class _StepOneScreenState extends State<StepOneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyBillController = TextEditingController();
  final _electricityRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final viewModel = context.read<QuoteGenerationViewModel>();
    _monthlyBillController.text = viewModel.monthlyBillKwh.toString();
    _electricityRateController.text = viewModel.electricityRate.toString();
  }

  @override
  void dispose() {
    _monthlyBillController.dispose();
    _electricityRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteGenerationViewModel>(
      builder: (context, viewModel, child) {
        final stepInfo = viewModel.getStepInfo(1);

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Step header
              StepHeaderWidget(
                title: stepInfo.title,
                description: stepInfo.description,
              ),

              const SizedBox(height: 21),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Monthly bill input
                      _buildMonthlyBillSection(viewModel),

                      const SizedBox(height: 24),

                      // Bill offset percentage
                      _buildBillOffsetSection(viewModel),

                      const SizedBox(height: 24),

                      // Sun hours per day
                      _buildSunHoursSection(viewModel),

                      const SizedBox(height: 24),

                      // Off-grid setup
                      _buildOffGridSection(viewModel),

                      const SizedBox(height: 32),

                      // Error message
                      if (viewModel.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade600),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Calculate button
                      CustomButton(
                        text: AppStrings.calculateButton,
                        onPressed: _canCalculate(viewModel)
                            ? () => _handleCalculate(viewModel)
                            : null,
                        isLoading: viewModel.isCalculating,
                      ),
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

  /// Build monthly bill input section
  Widget _buildMonthlyBillSection(QuoteGenerationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PHP input (default)
        if (!viewModel.usedPhpBilling) ...[
          CustomTextField(
            label: AppStrings.monthlyElectricBillPhpLabel,
            controller: _monthlyBillController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) =>
                Validators.validatePositiveNumber(value, 'Monthly bill'),
            onChanged: (value) {
              final numValue = double.tryParse(value) ?? 0;
              viewModel.updateMonthlyBillKwh(numValue);
            },
          ),
        ],

        // kWh input (when checked)
        if (viewModel.usedPhpBilling) ...[
          CustomTextField(
            label: AppStrings.monthlyElectricBillLabel,
            controller: _monthlyBillController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) =>
                Validators.validatePositiveNumber(value, 'Monthly bill (kWh)'),
            onChanged: (value) {
              final numValue = double.tryParse(value) ?? 0;
              viewModel.updateMonthlyBillKwh(numValue);
            },
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: AppStrings.electricityProviderRateLabel,
            controller: _electricityRateController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) =>
                Validators.validatePositiveNumber(value, 'Electricity rate'),
            onChanged: (value) {
              final numValue = double.tryParse(value) ?? 0;
              viewModel.updateElectricityRate(numValue);
            },
          ),
        ],

        // Checkbox below the text field(s)
        Row(
          children: [
            Checkbox(
              value: viewModel.usedPhpBilling,
              onChanged: (value) => viewModel.togglePhpBilling(value ?? false),
            ),
            const Text('Enter in kWh'),
          ],
        ),
      ],
    );
  }

  /// Build bill offset percentage section
  Widget _buildBillOffsetSection(QuoteGenerationViewModel viewModel) {
    return SliderInputWidget(
      label: AppStrings.billOffsetPercentageLabel,
      description: AppStrings.billOffsetDescription,
      value: viewModel.billOffsetPercentage,
      min: 0,
      max: 100,
      divisions: 20,
      suffix: '%',
      onChanged: viewModel.updateBillOffsetPercentage,
    );
  }

  /// Build sun hours section
  Widget _buildSunHoursSection(QuoteGenerationViewModel viewModel) {
    return SliderInputWidget(
      label: AppStrings.sunHoursLabel,
      description: AppStrings.sunHoursDescription,
      value: viewModel.sunHoursPerDay,
      min: 1,
      max: 12,
      divisions: 22,
      suffix: ' hours',
      onChanged: viewModel.updateSunHoursPerDay,
    );
  }

  /// Build off-grid setup section
  Widget _buildOffGridSection(QuoteGenerationViewModel viewModel) {
    return Column(
      children: [
        CustomCheckbox(
          label: AppStrings.offGridSetupLabel,
          value: viewModel.isOffGrid,
          onChanged: (value) => viewModel.toggleOffGrid(value ?? false),
        ),
        if (viewModel.isOffGrid) ...[
          const SizedBox(height: 16),
          SliderInputWidget(
            label: AppStrings.backupDurationLabel,
            description: AppStrings.backupDurationDescription,
            value: viewModel.backupHours,
            min: 1,
            max: 24,
            divisions: 23,
            suffix: ' hours',
            onChanged: viewModel.updateBackupHours,
          ),
        ],
      ],
    );
  }

  /// Check if calculation can be performed
  bool _canCalculate(QuoteGenerationViewModel viewModel) {
    return viewModel.monthlyBillKwh > 0 &&
        viewModel.sunHoursPerDay > 0 &&
        (!viewModel.usedPhpBilling || viewModel.electricityRate > 0);
  }

  /// Handle calculate button press
  Future<void> _handleCalculate(QuoteGenerationViewModel viewModel) async {
    if (_formKey.currentState?.validate() ?? false) {
      await viewModel.calculateSystem();

      if (viewModel.calculationResult != null &&
          viewModel.errorMessage == null) {
        // Navigate to calculation results
        if (mounted) {
          Navigator.pushNamed(context, '/calculation-results');
        }
      }
    }
  }
}
