import 'package:flutter/material.dart';
import '../../../../data/models/preset_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';

/// Widget for displaying a preset item in the list
class PresetItemWidget extends StatelessWidget {
  final PresetModel preset;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PresetItemWidget({
    super.key,
    required this.preset,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: AppTypography.interSemiBoldBlack18_24_0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${preset.itemCount} items • ₱${preset.totalEstimatedPrice.toStringAsFixed(2)}',
                      style: AppTypography.interRegularGray14_20_0,
                    ),
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              Transform.translate(
                offset: const Offset(16, 0),
                child: IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit,
                    size: 20,
                    color: AppColors.primaryColor,
                  ),
                  tooltip: 'Edit preset',
                ),
              ),
            if (onDelete != null)
              Transform.translate(
                offset: const Offset(8, 0),
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.red,
                  ),
                  tooltip: 'Delete preset',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
