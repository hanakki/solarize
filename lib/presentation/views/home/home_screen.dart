import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/common/background_container.dart';
import 'widgets/feature_card_widget.dart';
import 'widgets/date_display_widget.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';

/// Home screen displaying the main navigation cards
/// Shows today's date and four feature cards for main app functions
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App title (optional, can be removed if not needed)
                    const SizedBox(height: 20),

                    // Today section
                    _buildTodaySection(viewModel),

                    const SizedBox(height: 30),

                    // Feature cards grid
                    _buildFeatureCardsGrid(context, viewModel),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build the today section with date display
  Widget _buildTodaySection(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Today" label
        Text(
          viewModel.todayLabel,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: AppColors.primaryTextColor,
          ),
        ),

        const SizedBox(height: 8),

        // Date display
        DateDisplayWidget(
          formattedDate: viewModel.formattedDate,
        ),
      ],
    );
  }

  /// Build the feature cards grid (2x2 layout)
  Widget _buildFeatureCardsGrid(BuildContext context, HomeViewModel viewModel) {
    final cards = viewModel.featureCards;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85, // Adjust this to control card height
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return FeatureCardWidget(
          title: card.title,
          description: card.description,
          iconPath: card.iconPath,
          onTap: () => viewModel.navigateToFeature(context, card.route),
        );
      },
    );
  }
}
