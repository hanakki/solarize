import 'package:flutter/material.dart';
import '../../../../core/constants/typography.dart';

// for slider input with label, description, and value display
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.interSemiBoldGray12_16_15,
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: AppTypography.interRegularGray14_20_0,
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '${value.toStringAsFixed(1)}$suffix',
            style: AppTypography.interRegularBlack16_24_05,
          ),
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            thumbColor: const Color(0xFF0D369C),
            activeTrackColor: const Color(0xFF0077D3),
            inactiveTrackColor: const Color(0xFFA4A3B3),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            divisions: divisions,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${min.toStringAsFixed(1)}$suffix',
              style: AppTypography.interRegularGray14_20_0,
            ),
            Text(
              '${max.toStringAsFixed(1)}$suffix',
              style: AppTypography.interRegularGray14_20_0,
            ),
          ],
        ),
      ],
    );
  }
}
