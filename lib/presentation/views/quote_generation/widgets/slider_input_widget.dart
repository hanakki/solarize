import 'package:flutter/material.dart';

/// Widget for slider input with label, description, and value display
class SliderInputWidget extends StatelessWidget {
  final String label;
  final String description;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double> onChanged;

  const SliderInputWidget({
    super.key,
    required this.label,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 16),

          // Value display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${value.toStringAsFixed(1)}$suffix',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Slider
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveColor: Colors.grey.shade300,
          ),

          // Min and max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toStringAsFixed(1)}$suffix',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${max.toStringAsFixed(1)}$suffix',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
