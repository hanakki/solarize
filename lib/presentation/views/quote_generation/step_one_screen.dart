import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../widgets/common/custom_text_field.dart';
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
  final _solarPanelSizeController = TextEditingController();
  final _solarPanelPriceController = TextEditingController();
  final _batterySizeController = TextEditingController();
  final _batteryPriceController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final viewModel = context.read<QuoteGenerationViewModel>();
    _monthlyBillController.text = viewModel.monthlyBillKwh.toString();
    _electricityRateController.text = viewModel.electricityRate.toString();
    _solarPanelSizeController.text = viewModel.solarPanelSizeKw.toString();
    _solarPanelPriceController.text = viewModel.solarPanelPricePhp.toString();
    _batterySizeController.text = viewModel.batterySizeKwh.toString();
    _batteryPriceController.text = viewModel.batteryPricePhp.toString();
    _latitudeController.text = viewModel.latitude.toString();
    _longitudeController.text = viewModel.longitude.toString();
  }

  @override
  void dispose() {
    _monthlyBillController.dispose();
    _electricityRateController.dispose();
    _solarPanelSizeController.dispose();
    _solarPanelPriceController.dispose();
    _batterySizeController.dispose();
    _batteryPriceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
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

                      // Sun hours per day (only show when API is disabled)
                      if (!viewModel.useApiIntegration) ...[
                        _buildSunHoursSection(viewModel),
                        const SizedBox(height: 24),
                      ],

                      // API Integration toggle
                      _buildApiIntegrationSection(viewModel),

                      const SizedBox(height: 16),

                      // Location input (only show when API is enabled)
                      if (viewModel.useApiIntegration) ...[
                        _buildLocationSection(viewModel),
                        const SizedBox(height: 24),
                      ],

                      // Solar Panel Configuration
                      _buildSolarPanelSection(viewModel),

                      const SizedBox(height: 24),

                      // Off-grid setup
                      _buildOffGridSection(viewModel),

                      const SizedBox(height: 24),

                      // Battery Configuration (only show when off-grid is enabled)
                      if (viewModel.isOffGrid) ...[
                        _buildBatterySection(viewModel),
                        const SizedBox(height: 24),
                      ],

                      const SizedBox(height: 45),

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
        // kWh input
        if (!viewModel.usedPhpBilling) ...[
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
        ],

        // kWh input (when checked)
        if (viewModel.usedPhpBilling) ...[
          CustomTextField(
            label: AppStrings.monthlyElectricBillPhpLabel,
            controller: _monthlyBillController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) =>
                Validators.validatePositiveNumber(value, 'Monthly bill (kWh)'),
            onChanged: (value) {
              final numValue = double.tryParse(value) ?? 0;
              viewModel.updateMonthlyBillPhp(numValue);
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
              activeColor: const Color(0xFF0077D3),
            ),
            const Text(AppStrings.electricBillPhpToggle),
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

  /// Build sun hours per day section
  Widget _buildSunHoursSection(QuoteGenerationViewModel viewModel) {
    return SliderInputWidget(
      label: AppStrings.sunHoursLabel,
      description: AppStrings.sunHoursDescription,
      value: viewModel.sunHoursPerDay,
      min: 1,
      max: 8,
      divisions: 14,
      suffix: ' hours',
      onChanged: viewModel.updateSunHoursPerDay,
    );
  }

  /// Build API integration section
  Widget _buildApiIntegrationSection(QuoteGenerationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.apiIntegrationLabel,
            style: AppTypography.interSemiBoldGray12_16_15),
        Transform.translate(
          offset: const Offset(-14, 0),
          child: Row(
            children: [
              Checkbox(
                value: viewModel.useApiIntegration,
                onChanged: (value) =>
                    viewModel.toggleApiIntegration(value ?? false),
                activeColor: const Color(0xFF0077D3),
              ),
              const Text(AppStrings.apiIntegrationToggle),
            ],
          ),
        ),
      ],
    );
  }

  /// Build location input section
  Widget _buildLocationSection(QuoteGenerationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   AppStrings.locationConfigurationTitle,
        //   style: AppTypography.interSemiBoldGray12_16_15,
        // ),
        // const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: AppStrings.latitudeLabel,
                controller: _latitudeController,
                hint: AppStrings.latitudeHint,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) =>
                    Validators.validatePositiveNumber(value, 'Latitude'),
                onChanged: (value) {
                  final numValue = double.tryParse(value) ?? 0;
                  viewModel.updateLocation(numValue, viewModel.longitude);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: AppStrings.longitudeLabel,
                controller: _longitudeController,
                hint: AppStrings.longitudeHint,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) =>
                    Validators.validatePositiveNumber(value, 'Longitude'),
                onChanged: (value) {
                  final numValue = double.tryParse(value) ?? 0;
                  viewModel.updateLocation(viewModel.latitude, numValue);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build solar panel configuration section
  Widget _buildSolarPanelSection(QuoteGenerationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   AppStrings.solarPanelConfigurationTitle,
        //   style: AppTypography.interSemiBoldGray12_16_15,
        // ),
        // const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: AppStrings.solarPanelSizeLabel,
                controller: _solarPanelSizeController,
                hint: AppStrings.solarPanelSizeHint,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) =>
                    Validators.validatePositiveNumber(value, 'Panel size'),
                onChanged: (value) {
                  final numValue = double.tryParse(value) ?? 0;
                  viewModel.updateSolarPanelSize(numValue);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: AppStrings.solarPanelPriceLabel,
                controller: _solarPanelPriceController,
                hint: AppStrings.solarPanelPriceHint,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) =>
                    Validators.validatePositiveNumber(value, 'Panel price'),
                onChanged: (value) {
                  final numValue = double.tryParse(value) ?? 0;
                  viewModel.updateSolarPanelPrice(numValue);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build off-grid setup section
  Widget _buildOffGridSection(QuoteGenerationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.systemSetupLabel,
          style: AppTypography.interSemiBoldGray12_16_15,
        ),
        Transform.translate(
          offset: const Offset(-14, 0),
          child: Row(
            children: [
              Checkbox(
                value: viewModel.isOffGrid,
                onChanged: (value) => viewModel.toggleOffGrid(value ?? false),
                activeColor: const Color(0xFF0077D3),
              ),
              const Text(AppStrings.offGridSetupLabel),
            ],
          ),
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

  /// Build battery configuration section
  Widget _buildBatterySection(QuoteGenerationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   AppStrings.batteryConfigurationTitle,
        //   style: AppTypography.interSemiBoldGray12_16_15,
        // ),
        // const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: AppStrings.batterySizeLabel,
                controller: _batterySizeController,
                hint: AppStrings.batterySizeHint,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) =>
                    Validators.validatePositiveNumber(value, 'Battery size'),
                onChanged: (value) {
                  final numValue = double.tryParse(value) ?? 0;
                  viewModel.updateBatterySize(numValue);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: AppStrings.batteryPriceLabel,
                controller: _batteryPriceController,
                hint: AppStrings.batteryPriceHint,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) =>
                    Validators.validatePositiveNumber(value, 'Battery price'),
                onChanged: (value) {
                  final numValue = double.tryParse(value) ?? 0;
                  viewModel.updateBatteryPrice(numValue);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Check if calculation can be performed
  bool _canCalculate(QuoteGenerationViewModel viewModel) {
    if (viewModel.monthlyBillKwh <= 0) return false;
    if (viewModel.billOffsetPercentage <= 0) return false;
    if (!viewModel.useApiIntegration && viewModel.sunHoursPerDay <= 0)
      return false;
    if (viewModel.useApiIntegration &&
        (viewModel.latitude <= 0 || viewModel.longitude <= 0)) return false;
    if (viewModel.solarPanelSizeKw <= 0) return false;
    if (viewModel.solarPanelPricePhp <= 0) return false;
    if (viewModel.isOffGrid) {
      if (viewModel.backupHours <= 0) return false;
      if (viewModel.batterySizeKwh <= 0) return false;
      if (viewModel.batteryPricePhp <= 0) return false;
    }
    return true;
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
