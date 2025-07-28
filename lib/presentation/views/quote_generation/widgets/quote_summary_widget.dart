import 'package:flutter/material.dart';
import '../../../../data/models/calculation_result_model.dart';
import '../../../../data/models/project_details_model.dart';

/// Widget for displaying quote summary with calculation results and project details
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
          // Header
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

          // System details
          _buildSummarySection(
            'System Details',
            [
              _buildSummaryRow('System Size',
                  '${calculationResult.systemSize.toStringAsFixed(2)} kW'),
              _buildSummaryRow('System Type', calculationResult.systemType),
              if (calculationResult.isOffGrid)
                _buildSummaryRow('Battery Size',
                    '${calculationResult.batterySize.toStringAsFixed(2)} kWh'),
            ],
          ),

          const SizedBox(height: 16),

          // Financial details
          _buildSummarySection(
            'Financial Details',
            [
              _buildSummaryRow('Estimated Cost',
                  '₱${calculationResult.estimatedCost.toStringAsFixed(0)}'),
              _buildSummaryRow('Monthly Savings',
                  '₱${calculationResult.monthlySavings.toStringAsFixed(0)}'),
              _buildSummaryRow('Payback Period',
                  '${calculationResult.paybackPeriod.toStringAsFixed(1)} years'),
            ],
          ),

          const SizedBox(height: 16),

          // Project details
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
