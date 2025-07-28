import 'package:flutter/material.dart';

/// Widget for displaying step header with title and description
class StepHeaderWidget extends StatelessWidget {
  final String title;
  final String description;

  const StepHeaderWidget({
    super.key,
    required this.title,
    required this.description,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
