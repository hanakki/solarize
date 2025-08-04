import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../data/models/company_profile_model.dart';
import '../../../viewmodels/settings_viewmodel.dart';
import 'file_upload_widget.dart';

/// Widget for editing company profile information
class CompanyProfileWidget extends StatelessWidget {
  const CompanyProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
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
              _buildLogoSection(viewModel),
              const SizedBox(height: 24),
              _buildCompanyInfoSection(viewModel),
              const SizedBox(height: 24),
              _buildContactInfoSection(viewModel),
              const SizedBox(height: 24),
              _buildFooterSection(viewModel),
              const SizedBox(height: 24),
              _buildSaveButton(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.business,
          color: AppColors.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'Company Profile',
          style: AppTypography.interSemiBold18_24_0_black,
        ),
      ],
    );
  }

  Widget _buildLogoSection(SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Logo',
          style: AppTypography.interSemiBold16_24_0_black,
        ),
        const SizedBox(height: 12),
        FileUploadWidget(
          currentImagePath: viewModel.logoPath,
          onImageSelected: (file) => viewModel.uploadLogo(file),
          onImageRemoved: viewModel.removeLogo,
          isLoading: viewModel.isUploadingLogo,
        ),
      ],
    );
  }

  Widget _buildCompanyInfoSection(SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Information',
          style: AppTypography.interSemiBold16_24_0_black,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: viewModel.companyNameController,
          label: 'Company Name *',
          hint: 'Enter your company name',
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: viewModel.addressController,
          label: 'Address',
          hint: 'Enter company address',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection(SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: AppTypography.interSemiBold16_24_0_black,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: viewModel.phoneNumberController,
          label: 'Mobile Number',
          hint: 'Enter mobile number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: viewModel.telephoneNumberController,
          label: 'Telephone Number',
          hint: 'Enter telephone number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: viewModel.emailController,
          label: 'Email Address',
          hint: 'Enter email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: viewModel.websiteController,
          label: 'Website',
          hint: 'Enter website URL',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildFooterSection(SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PDF Footer Information',
          style: AppTypography.interSemiBold16_24_0_black,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: viewModel.footerNotesController,
          label: 'Footer Notes',
          hint: 'Enter additional notes for PDF footer',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: viewModel.preparedByController,
          label: 'Prepared By',
          hint: 'Enter name of person preparing quotes',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.interSemiBold16_24_0_black,
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontFamily: 'InterSemiBold',
                  fontSize: 16,
                  height: 24 / 16,
                  letterSpacing: 0,
                  color: AppColors.errorColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.interRegular14_20_0_gray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(SettingsViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isSaving ? null : viewModel.saveCompanyProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: viewModel.isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save Company Profile',
                style: AppTypography.interSemiBold14_16_15_white,
              ),
      ),
    );
  }
}
