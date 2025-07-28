import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';

/// Accordion widget for expandable content sections
/// Used for project rows in quote generation
class AccordionWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final bool isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const AccordionWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.isExpanded = false,
    this.onExpansionChanged,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryTextColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryTextColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: trailing,
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.borderRadiusMedium),
                  bottomRight: Radius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
