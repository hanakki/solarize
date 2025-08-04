import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';

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
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildAppInfo(),
          const SizedBox(height: 24),
          _buildAboutUs(),
          const SizedBox(height: 24),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: AppColors.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'About',
          style: AppTypography.interSemiBold18_24_0_black,
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Solarize',
          style: AppTypography.interSemiBold16_24_0_black,
        ),
        const SizedBox(height: 12),
        Text(
          'Solarize is a comprehensive solar quotation app designed for solar consultants and installers. '
          'It helps you create professional solar quotations with accurate calculations, '
          'detailed system specifications, and beautiful PDF exports.',
          style: AppTypography.interRegular16_24_0_black,
        ),
        const SizedBox(height: 16),
        Text(
          'Key Features:',
          style: AppTypography.interSemiBold16_24_0_black,
        ),
        const SizedBox(height: 8),
        _buildFeatureItem('• Accurate solar system sizing using PVWatts API'),
        _buildFeatureItem('• Professional PDF quotation generation'),
        _buildFeatureItem('• Company branding and customization'),
        _buildFeatureItem('• Grid-tied and off-grid system support'),
        _buildFeatureItem('• Detailed cost analysis and payback calculations'),
        _buildFeatureItem('• Easy sharing and export options'),
      ],
    );
  }

  Widget _buildAboutUs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Us',
          style: AppTypography.interSemiBold16_24_0_black,
        ),
        const SizedBox(height: 12),
        Text(
          'We are dedicated to advancing solar energy adoption in the Philippines and beyond. '
          'Our mission is to provide solar consultants with the tools they need to create '
          'accurate, professional, and compelling solar quotations that help clients make '
          'informed decisions about their renewable energy investments.',
          style: AppTypography.interRegular16_24_0_black,
        ),
        const SizedBox(height: 16),
        Text(
          'Our commitment to sustainability and innovation drives us to continuously improve '
          'our platform, ensuring that solar consultants have access to the most accurate '
          'calculations and professional presentation tools available.',
          style: AppTypography.interRegular16_24_0_black,
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
          Text(
            'App Information',
            style: AppTypography.interSemiBold16_24_0_black,
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Version', '1.0.0'),
          _buildInfoRow('Build', '1'),
          _buildInfoRow('Platform', 'Flutter'),
          _buildInfoRow('Last Updated', 'December 2024'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTypography.interRegular14_20_0_gray,
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
            style: AppTypography.interRegular14_20_0_gray,
          ),
          Text(
            value,
            style: AppTypography.interSemiBold16_24_0_black,
          ),
        ],
      ),
    );
  }
}
