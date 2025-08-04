import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/constants/strings.dart';

/// Screen showing calculation results after Step 1
/// Displays system size, battery size, costs, and savings
class CalculationResultsScreen extends StatelessWidget {
  const CalculationResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Consumer<QuoteGenerationViewModel>(
          builder: (context, viewModel, child) {
            final result = viewModel.calculationResult;

            if (result == null) {
              return const Center(
                child: Text('No calculation results available'),
              );
            }

            return Column(
              children: [
                const CustomAppBar(title: 'Calculation Results'),

                // Step Header and Progress Indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Step 1: Calculate System Size',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green[600]!,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calculation Complete',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // White Container with Results
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results in key-value format
                        _buildResultRow('System Size',
                            '${result.systemSize.toStringAsFixed(2)} kW'),
                        _buildDivider(),
                        _buildResultRow('Setup',
                            viewModel.isOffGrid ? 'Hybrid' : 'Grid-Tied'),
                        _buildDivider(),
                        _buildResultRow('System Cost',
                            '₱${result.estimatedCost.toStringAsFixed(0)}'),
                        _buildDivider(),
                        if (viewModel.isOffGrid) ...[
                          _buildResultRow('Battery Storage',
                              '${result.batterySize.toStringAsFixed(2)} kWh'),
                          _buildDivider(),
                          _buildResultRow('Battery Cost',
                              '₱${result.batteryCost.toStringAsFixed(0)}'),
                          _buildDivider(),
                        ],
                        _buildResultRow(
                            'Number of Panels', '${result.numberOfPanels} pcs'),
                        _buildDivider(),
                        if (viewModel.isOffGrid) ...[
                          _buildResultRow('Number of Batteries',
                              '${result.numberOfBatteries} pcs'),
                          _buildDivider(),
                        ],
                        _buildResultRow('Annual Production',
                            '${result.annualProduction.toStringAsFixed(0)} kWh'),
                        _buildDivider(),
                        _buildResultRow('Monthly Production',
                            '${result.monthlyProduction.toStringAsFixed(0)} kWh'),
                        _buildDivider(),
                      ],
                    ),
                  ),
                ),

                // Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Proceed Button (Primary)
                      CustomButton(
                        text: AppStrings.proceedButton,
                        onPressed: () {
                          viewModel.nextStep();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Back Button (Secondary)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      height: 1,
      thickness: 1,
    );
  }

  // ===== DEBUG SECTION START - COMMENT OUT FOR PRODUCTION =====
  Widget _buildDebugSection(QuoteGenerationViewModel viewModel) {
    return ExpansionTile(
      title: const Text(
        '🔧 Debug Information',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      subtitle: const Text(
        'Click to view calculation details (Remove for production)',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Input Variables:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDebugRow('Monthly Bill',
                  '${viewModel.monthlyBillKwh.toStringAsFixed(2)} kWh'),
              _buildDebugRow('Bill Offset',
                  '${viewModel.billOffsetPercentage.toStringAsFixed(1)}%'),
              _buildDebugRow(
                  'Used PHP Billing', viewModel.usedPhpBilling ? 'Yes' : 'No'),
              if (viewModel.usedPhpBilling)
                _buildDebugRow('Electricity Rate',
                    '₱${viewModel.electricityRate.toStringAsFixed(2)}/kWh'),
              _buildDebugRow('API Integration',
                  viewModel.useApiIntegration ? 'Yes' : 'No'),
              if (!viewModel.useApiIntegration)
                _buildDebugRow('Sun Hours/Day',
                    '${viewModel.sunHoursPerDay.toStringAsFixed(1)} hours'),
              if (viewModel.useApiIntegration) ...[
                _buildDebugRow(
                    'Latitude', viewModel.latitude.toStringAsFixed(4)),
                _buildDebugRow(
                    'Longitude', viewModel.longitude.toStringAsFixed(4)),
              ],
              _buildDebugRow('Is Off-Grid', viewModel.isOffGrid ? 'Yes' : 'No'),
              if (viewModel.isOffGrid) ...[
                _buildDebugRow('Backup Hours',
                    '${viewModel.backupHours.toStringAsFixed(1)} hours'),
              ],
              _buildDebugRow('Solar Panel Size',
                  '${viewModel.solarPanelSizeKw.toStringAsFixed(2)} kW'),
              _buildDebugRow('Solar Panel Price',
                  '₱${viewModel.solarPanelPricePhp.toStringAsFixed(0)}'),
              if (viewModel.isOffGrid) ...[
                _buildDebugRow('Battery Size',
                    '${viewModel.batterySizeKwh.toStringAsFixed(2)} kWh'),
                _buildDebugRow('Battery Price',
                    '₱${viewModel.batteryPricePhp.toStringAsFixed(0)}'),
              ],
              const SizedBox(height: 16),
              const Text(
                'Calculation Results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDebugRow('System Size',
                  '${viewModel.calculationResult?.systemSize.toStringAsFixed(2)} kW'),
              _buildDebugRow('Annual Production',
                  '${viewModel.calculationResult?.annualProduction?.toStringAsFixed(0) ?? '0'} kWh'),
              _buildDebugRow('Monthly Production',
                  '${viewModel.calculationResult?.monthlyProduction?.toStringAsFixed(0) ?? '0'} kWh'),
              if (viewModel.isOffGrid)
                _buildDebugRow('Battery Size',
                    '${viewModel.calculationResult?.batterySize.toStringAsFixed(2)} kWh'),
              _buildDebugRow('Number of Panels',
                  '${viewModel.calculationResult?.numberOfPanels} pcs'),
              if (viewModel.isOffGrid)
                _buildDebugRow('Number of Batteries',
                    '${viewModel.calculationResult?.numberOfBatteries} pcs'),
              _buildDebugRow('Solar Panel Cost',
                  '₱${viewModel.calculationResult?.solarPanelCost.toStringAsFixed(0)}'),
              if (viewModel.isOffGrid)
                _buildDebugRow('Battery Cost',
                    '₱${viewModel.calculationResult?.batteryCost.toStringAsFixed(0)}'),
              _buildDebugRow('Total System Cost',
                  '₱${viewModel.calculationResult?.estimatedCost.toStringAsFixed(0)}'),
              if (viewModel.useApiIntegration &&
                  viewModel.calculationResult?.pvwattsAnnualOutput != null)
                _buildDebugRow('PVWatts Annual Output',
                    '${viewModel.calculationResult?.pvwattsAnnualOutput?.toStringAsFixed(0)} kWh'),
              if (!viewModel.useApiIntegration &&
                  viewModel.calculationResult?.sunHoursPerDay != null)
                _buildDebugRow('Sun Hours/Day',
                    '${viewModel.calculationResult?.sunHoursPerDay?.toStringAsFixed(1)} hours'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ===== DEBUG SECTION END - COMMENT OUT FOR PRODUCTION =====
}
