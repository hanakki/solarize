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
                                if (result.isOffGrid)
                                  CalculationResultCard(
                                    title: 'Battery Storage Required',
                                    value:
                                        '${result.batterySize.toStringAsFixed(2)} kWh',
                                    subtitle:
                                        'For ${viewModel.backupHours.toStringAsFixed(0)} hours backup',
                                    icon: Icons.battery_full,
                                    color: Colors.green,
                                  ),

                                if (result.isOffGrid)
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
                                      '₱${result.monthlySavings.toStringAsFixed(0)}',
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
                                      '${result.paybackPeriod.toStringAsFixed(1)} years',
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
                                    color: result.isOffGrid
                                        ? Colors.orange.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: result.isOffGrid
                                          ? Colors.orange.shade200
                                          : Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        result.isOffGrid
                                            ? Icons.power_off
                                            : Icons.electrical_services,
                                        color: result.isOffGrid
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
                                              result.isOffGrid
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
              _buildDebugRow('Sun Hours/Day',
                  '${viewModel.sunHoursPerDay.toStringAsFixed(1)} hours'),
              _buildDebugRow('Is Off-Grid', viewModel.isOffGrid ? 'Yes' : 'No'),
              if (viewModel.isOffGrid)
                _buildDebugRow('Backup Hours',
                    '${viewModel.backupHours.toStringAsFixed(1)} hours'),
              _buildDebugRow(
                  'Used PHP Billing', viewModel.usedPhpBilling ? 'Yes' : 'No'),
              if (viewModel.usedPhpBilling)
                _buildDebugRow('Electricity Rate',
                    '₱${viewModel.electricityRate.toStringAsFixed(2)}/kWh'),
              _buildDebugRow('Latitude', viewModel.latitude.toStringAsFixed(4)),
              _buildDebugRow(
                  'Longitude', viewModel.longitude.toStringAsFixed(4)),
              const SizedBox(height: 16),
              const Text(
                'Calculation Results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDebugRow('System Size',
                  '${viewModel.calculationResult?.systemSize.toStringAsFixed(2)} kW'),
              _buildDebugRow('Battery Size',
                  '${viewModel.calculationResult?.batterySize.toStringAsFixed(2)} kWh'),
              _buildDebugRow('Total Cost',
                  '₱${viewModel.calculationResult?.estimatedCost.toStringAsFixed(2)}'),
              _buildDebugRow('Monthly Savings',
                  '₱${viewModel.calculationResult?.monthlySavings.toStringAsFixed(2)}'),
              _buildDebugRow('Payback Period',
                  '${viewModel.calculationResult?.paybackPeriod.toStringAsFixed(1)} years'),
              _buildDebugRow('Solar Radiation',
                  '${viewModel.calculationResult?.sunHoursPerDay.toStringAsFixed(2)} kWh/m²/day'),
              const SizedBox(height: 16),
              const Text(
                'Step-by-Step Calculations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // System Size Calculation
              _buildDebugRow('1. System Size', ''),
              _buildDebugRow('   Monthly kWh',
                  '${viewModel.monthlyBillKwh.toStringAsFixed(2)} kWh'),
              _buildDebugRow('   Bill Offset',
                  '${viewModel.billOffsetPercentage.toStringAsFixed(1)}%'),
              _buildDebugRow('   Monthly Offset',
                  '${(viewModel.monthlyBillKwh * viewModel.billOffsetPercentage / 100).toStringAsFixed(2)} kWh'),
              _buildDebugRow('   Daily Offset',
                  '${(viewModel.monthlyBillKwh * viewModel.billOffsetPercentage / 100 / 30).toStringAsFixed(2)} kWh'),
              _buildDebugRow('   Sun Hours/Day',
                  '${viewModel.sunHoursPerDay.toStringAsFixed(1)} hours'),
              _buildDebugRow('   System Size',
                  '${viewModel.calculationResult?.systemSize.toStringAsFixed(2)} kW'),
              _buildDebugRow('   Formula',
                  '${(viewModel.monthlyBillKwh * viewModel.billOffsetPercentage / 100 / 30).toStringAsFixed(2)} ÷ ${viewModel.sunHoursPerDay.toStringAsFixed(1)} = ${viewModel.calculationResult?.systemSize.toStringAsFixed(2)} kW'),

              const SizedBox(height: 8),

              // Cost Calculation
              _buildDebugRow('2. System Cost', ''),
              _buildDebugRow('   Solar Panels',
                  '${viewModel.calculationResult?.systemSize.toStringAsFixed(2)} kW × 1000 × ₱45 = ₱${(viewModel.calculationResult?.systemSize ?? 0 * 1000 * 45).toStringAsFixed(0)}'),
              _buildDebugRow('   Installation', '₱50,000'),
              if (viewModel.isOffGrid) ...[
                _buildDebugRow('   Battery',
                    '${viewModel.calculationResult?.batterySize.toStringAsFixed(2)} kWh × ₱25,000 = ₱${(viewModel.calculationResult?.batterySize ?? 0 * 25000).toStringAsFixed(0)}'),
              ] else ...[
                _buildDebugRow('   Battery', 'Not required (grid-tied)'),
              ],
              _buildDebugRow('   Total Cost',
                  '₱${viewModel.calculationResult?.estimatedCost.toStringAsFixed(0)}'),

              const SizedBox(height: 8),

              // Savings Calculation
              _buildDebugRow('3. Monthly Savings', ''),
              _buildDebugRow('   Monthly Production',
                  '${(viewModel.calculationResult?.monthlySavings ?? 0 / viewModel.electricityRate).toStringAsFixed(2)} kWh'),
              _buildDebugRow('   Electricity Rate',
                  '₱${viewModel.electricityRate.toStringAsFixed(2)}/kWh'),
              _buildDebugRow('   Monthly Savings',
                  '₱${viewModel.calculationResult?.monthlySavings.toStringAsFixed(0)}'),
              _buildDebugRow('   Formula',
                  '${(viewModel.calculationResult?.monthlySavings ?? 0 / viewModel.electricityRate).toStringAsFixed(2)} × ₱${viewModel.electricityRate.toStringAsFixed(2)} = ₱${viewModel.calculationResult?.monthlySavings.toStringAsFixed(0)}'),

              const SizedBox(height: 8),

              // Payback Calculation
              _buildDebugRow('4. Payback Period', ''),
              _buildDebugRow('   Total Cost',
                  '₱${viewModel.calculationResult?.estimatedCost.toStringAsFixed(0)}'),
              _buildDebugRow('   Monthly Savings',
                  '₱${viewModel.calculationResult?.monthlySavings.toStringAsFixed(0)}'),
              _buildDebugRow('   Annual Savings',
                  '₱${(viewModel.calculationResult?.monthlySavings ?? 0 * 12).toStringAsFixed(0)}'),
              _buildDebugRow('   Payback Years',
                  '${viewModel.calculationResult?.paybackPeriod.toStringAsFixed(1)} years'),
              _buildDebugRow('   Formula',
                  '₱${viewModel.calculationResult?.estimatedCost.toStringAsFixed(0)} ÷ ₱${(viewModel.calculationResult?.monthlySavings ?? 0 * 12).toStringAsFixed(0)} = ${viewModel.calculationResult?.paybackPeriod.toStringAsFixed(1)} years'),

              if (viewModel.isOffGrid) ...[
                const SizedBox(height: 8),
                _buildDebugRow('5. Battery Size', ''),
                _buildDebugRow('   Daily Consumption',
                    '${(viewModel.monthlyBillKwh / 30).toStringAsFixed(2)} kWh'),
                _buildDebugRow('   Hourly Consumption',
                    '${(viewModel.monthlyBillKwh / 30 / 24).toStringAsFixed(2)} kWh'),
                _buildDebugRow('   Backup Hours',
                    '${viewModel.backupHours.toStringAsFixed(1)} hours'),
                _buildDebugRow('   Battery Size',
                    '${viewModel.calculationResult?.batterySize.toStringAsFixed(2)} kWh'),
                _buildDebugRow('   Formula',
                    '${(viewModel.monthlyBillKwh / 30 / 24).toStringAsFixed(2)} × ${viewModel.backupHours.toStringAsFixed(1)} = ${viewModel.calculationResult?.batterySize.toStringAsFixed(2)} kWh'),
              ],
              const SizedBox(height: 16),
              const Text(
                'PVWatts API Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDebugRow('Module Type', 'Standard (0)'),
              _buildDebugRow('Array Type', 'Fixed Roof Mounted (1)'),
              _buildDebugRow('Tilt Angle', '15.0°'),
              _buildDebugRow('Azimuth', '180.0° (South)'),
              _buildDebugRow('System Losses', '14.0%'),
              _buildDebugRow('DC/AC Ratio', '1.2'),
              _buildDebugRow('Inverter Efficiency', '96.0%'),
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
