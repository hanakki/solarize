import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/constants/strings.dart';

/// Widget for displaying app and company information
class AboutSectionWidget extends StatelessWidget {
  const AboutSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppInfo(),
          const SizedBox(height: 24),
          _buildAboutUs(),
          const SizedBox(height: 24),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.aboutAppTitle,
          style: AppTypography.interSemiBoldBlack18_24_0,
        ),
        SizedBox(height: 16),
        Text(
          AppStrings.aboutAppDescription,
          style: AppTypography.interRegularBlack16_24_0,
        ),
      ],
    );
  }

  Widget _buildAboutUs() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.aboutUsTitle,
          style: AppTypography.interSemiBoldBlack18_24_0,
        ),
        SizedBox(height: 16),
        Text(
          AppStrings.aboutUsDescription,
          style: AppTypography.interRegularBlack16_24_0,
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Information',
            style: AppTypography.interSemiBoldBlack16_24_0,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Version', '1.0.0'),
          _buildInfoRow('Build', '1'),
          _buildInfoRow('Platform', 'Flutter'),
          _buildInfoRow('Last Updated', 'August 2025'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTypography.interRegularGray14_20_0,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.interRegularGray14_20_0,
          ),
          Text(
            value,
            style: AppTypography.interSemiBoldBlack16_24_0,
          ),
        ],
      ),
    );
  }
}
