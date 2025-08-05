import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solarize/presentation/widgets/common/custom_text_field.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/constants/strings.dart';
import '../../../viewmodels/settings_viewmodel.dart';
import 'file_upload_widget.dart';

// for editing company profile information
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
              _buildSaveButton(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Text(
          'Company Profile',
          style: AppTypography.interSemiBoldBlack18_24_0,
        ),
      ],
    );
  }

  Widget _buildLogoSection(SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.companyLogoLabel,
          style: AppTypography.interSemiBoldGray12_16_15,
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
        CustomTextField(
            label: AppStrings.companyNameLabel,
            hint: 'Enter your company name',
            controller: viewModel.companyNameController),
        const SizedBox(height: 16),
        CustomTextField(
            label: AppStrings.companyAddressLabel,
            hint: 'Enter company address',
            controller: viewModel.addressController,
            maxLines: 3),
      ],
    );
  }

  Widget _buildContactInfoSection(SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
            label: AppStrings.comapnyMobileLabel,
            hint: 'Enter mobile number',
            controller: viewModel.phoneNumberController,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        CustomTextField(
            label: AppStrings.companyPhoneLabel,
            hint: 'Enter telephone number',
            controller: viewModel.telephoneNumberController,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        CustomTextField(
            label: AppStrings.companyEmailLabel,
            hint: 'Enter email address',
            controller: viewModel.emailController,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        CustomTextField(
            label: AppStrings.companyWebsiteLabel,
            hint: 'Enter website URL',
            controller: viewModel.websiteController,
            keyboardType: TextInputType.url),
      ],
    );
  }

  Widget _buildFooterSection(SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: AppStrings.footerNotesLabel,
          hint: 'Enter additional notes for PDF footer',
          controller: viewModel.footerNotesController,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: AppStrings.preparedByLabel,
          hint: 'Enter name of person preparing quotes',
          controller: viewModel.preparedByController,
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, SettingsViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            viewModel.isSaving ? null : () => _handleSave(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
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
            : const Text(
                AppStrings.saveCompanyProfileButton,
                style: AppTypography.interSemiBoldWhite14_16_15,
              ),
      ),
    );
  }

  Future<void> _handleSave(
      BuildContext context, SettingsViewModel viewModel) async {
    final success = await viewModel.saveCompanyProfile();

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company profile saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                viewModel.errorMessage ?? 'Failed to save company profile'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
