import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/background_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/white_content_container.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'widgets/company_profile_widget.dart';
import 'widgets/about_section_widget.dart';
import '../../../core/constants/typography.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize settings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().initialize();
    });
  }

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
                child: Consumer<SettingsViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const SingleChildScrollView(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      // padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Company Profile Section
                          const CompanyProfileWidget(),

                          const SizedBox(height: 32),

                          // About Section
                          const AboutSectionWidget(),

                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
