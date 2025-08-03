import 'package:flutter/material.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/white_content_container.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/typography.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'Settings',
              ),
              Expanded(
                child: WhiteContentContainer(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Settings Screen',
                          style: AppTypography.interSemiBold22_28_0_black,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coming Soon',
                          style: AppTypography.interRegular16_24_05_gray,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
