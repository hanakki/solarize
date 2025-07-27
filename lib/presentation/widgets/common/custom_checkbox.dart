import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Custom checkbox widget with consistent styling
/// Supports both traditional checkbox and toggle-style checkbox
class CustomCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isToggleStyle; // For stylistic choice mentioned in requirements
  final String? description;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isToggleStyle = false,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    if (isToggleStyle) {
      return _buildToggleStyle();
    } else {
      return _buildCheckboxStyle();
    }
  }

  /// Build traditional checkbox style
  Widget _buildCheckboxStyle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(!value),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
      ],
    );
  }

  /// Build toggle style (appears as button but functions as checkbox)
  Widget _buildToggleStyle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color: value ? AppColors.primaryColor : AppColors.borderColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  value ? Icons.check_circle : Icons.radio_button_unchecked,
                  color:
                      value ? AppColors.primaryColor : AppColors.hintTextColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: value
                          ? AppColors.primaryColor
                          : AppColors.primaryTextColor,
                      fontWeight: value ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
      ],
    );
  }
}
