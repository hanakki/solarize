import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Reusable feature card widget for home screen
/// Displays an icon, title, and description with tap functionality
class FeatureCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final VoidCallback onTap;

  const FeatureCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          children: [
            // Image section (50% of card height)
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.borderRadius),
                    topRight: Radius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: Center(
                  child: _buildIcon(),
                ),
              ),
            ),

            // Text section (50% of card height)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Description
                    Expanded(
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryTextColor,
                          height: 1.3,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the icon widget
  /// Uses placeholder icons since we don't have actual image assets
  Widget _buildIcon() {
    IconData iconData;

    // Map icon paths to actual icons (since we don't have image assets)
    switch (iconPath) {
      case 'assets/images/generate_quote_icon.png':
        iconData = Icons.description;
        break;
      case 'assets/images/configure_presets_icon.png':
        iconData = Icons.settings;
        break;
      case 'assets/images/advanced_calculator_icon.png':
        iconData = Icons.calculate;
        break;
      case 'assets/images/app_settings_icon.png':
        iconData = Icons.tune;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Icon(
      iconData,
      size: 48,
      color: AppColors.primaryColor,
    );

    // TODO: Replace with actual image when assets are available
    // return Image.asset(
    //   iconPath,
    //   width: 48,
    //   height: 48,
    //   fit: BoxFit.contain,
    //   errorBuilder: (context, error, stackTrace) {
    //     return Icon(
    //       Icons.image_not_supported,
    //       size: 48,
    //       color: AppColors.primaryColor,
    //     );
    //   },
    // );
  }
}
