import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quote_generation_viewmodel.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/white_content_container.dart';
import '../../widgets/common/custom_button.dart';
import 'widgets/calculation_result_card.dart';
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
                Expanded(
                  child: WhiteContentContainer(
                    child: Column(
                      children: [
                        // Header
                        const Text(
                          'System Calculation Results',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Based on your inputs, here\'s what we recommend:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Results cards
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // System size card
                                CalculationResultCard(
                                  title: 'Recommended System Size',
                                  value:
                                      '${result.systemSize.toStringAsFixed(2)} kW',
                                  subtitle: 'Solar panel capacity needed',
                                  icon: Icons.solar_power,
                                  color: Colors.orange,
                                ),

                                const SizedBox(height: 16),

                                // Battery size card (if off-grid)
                                if (viewModel.isOffGrid)
                                  CalculationResultCard(
                                    title: 'Battery Storage Required',
                                    value:
                                        '${result.batterySize.toStringAsFixed(2)} kWh',
                                    subtitle:
                                        'For ${viewModel.backupHours.toStringAsFixed(0)} hours backup',
                                    icon: Icons.battery_full,
                                    color: Colors.green,
                                  ),

                                if (viewModel.isOffGrid)
                                  const SizedBox(height: 16),

                                // Estimated cost card
                                CalculationResultCard(
                                  title: 'Estimated System Cost',
                                  value:
                                      '₱${result.estimatedCost.toStringAsFixed(0)}',
                                  subtitle: 'Including installation',
                                  icon: Icons.attach_money,
                                  color: Colors.blue,
                                ),

                                const SizedBox(height: 16),

                                // Monthly savings card
                                CalculationResultCard(
                                  title: 'Monthly Savings',
                                  value:
                                      '₱${(result.annualProduction / 12 * viewModel.electricityRate).toStringAsFixed(0)}',
                                  subtitle:
                                      'Estimated electricity bill reduction',
                                  icon: Icons.savings,
                                  color: Colors.green,
                                ),

                                const SizedBox(height: 16),

                                // Payback period card
                                CalculationResultCard(
                                  title: 'Payback Period',
                                  value:
                                      '${(result.estimatedCost / (result.annualProduction / 12 * viewModel.electricityRate) / 12).toStringAsFixed(1)} years',
                                  subtitle: 'Time to recover investment',
                                  icon: Icons.timeline,
                                  color: Colors.purple,
                                ),

                                const SizedBox(height: 32),

                                // ===== DEBUG SECTION START - COMMENT OUT FOR PRODUCTION =====
                                _buildDebugSection(viewModel),
                                // ===== DEBUG SECTION END - COMMENT OUT FOR PRODUCTION =====

                                const SizedBox(height: 32),

                                // System type info
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: viewModel.isOffGrid
                                        ? Colors.orange.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: viewModel.isOffGrid
                                          ? Colors.orange.shade200
                                          : Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        viewModel.isOffGrid
                                            ? Icons.power_off
                                            : Icons.electrical_services,
                                        color: viewModel.isOffGrid
                                            ? Colors.orange
                                            : Colors.blue,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result.systemType,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              viewModel.isOffGrid
                                                  ? 'Includes battery backup for power outages'
                                                  : 'Connected to the electrical grid',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Continue button
                        CustomButton(
                          text: AppStrings.proceedButton,
                          onPressed: () {
                            viewModel.nextStep();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
