import 'package:flutter/material.dart';
import '../../../../data/models/calculation_result_model.dart';
import '../../../../data/models/project_details_model.dart';

// for displaying quote summary with calculation results and project details
class QuoteSummaryWidget extends StatelessWidget {
  final CalculationResultModel calculationResult;
  final ProjectDetailsModel projectDetails;

  const QuoteSummaryWidget({
    super.key,
    required this.calculationResult,
    required this.projectDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'Quote Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummarySection(
            'System Details',
            [
              _buildSummaryRow('System Size',
                  '${calculationResult.systemSize.toStringAsFixed(2)} kW'),
              _buildSummaryRow('System Type', calculationResult.systemType),
              _buildSummaryRow('Number of Panels',
                  '${calculationResult.numberOfPanels} pcs'),
              if (calculationResult.batterySize > 0)
                _buildSummaryRow('Battery Size',
                    '${calculationResult.batterySize.toStringAsFixed(2)} kWh'),
              if (calculationResult.numberOfBatteries > 0)
                _buildSummaryRow('Number of Batteries',
                    '${calculationResult.numberOfBatteries} pcs'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummarySection(
            'Financial Details',
            [
              _buildSummaryRow('Solar Panel Cost',
                  '₱${calculationResult.solarPanelCost.toStringAsFixed(0)}'),
              if (calculationResult.batteryCost > 0)
                _buildSummaryRow('Battery Cost',
                    '₱${calculationResult.batteryCost.toStringAsFixed(0)}'),
              _buildSummaryRow('Total System Cost',
                  '₱${calculationResult.estimatedCost.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummarySection(
            'Project Details',
            [
              _buildSummaryRow('Client Name', projectDetails.clientName),
              _buildSummaryRow('Project Location', projectDetails.location),
              _buildSummaryRow(
                  'Installation Date', projectDetails.installationDate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
