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
}
