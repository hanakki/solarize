import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/common/background_container.dart';
import 'widgets/feature_card_widget.dart';
import 'widgets/date_display_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/typography.dart';

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
                    const SizedBox(height: 16),
                    _buildTodaySection(viewModel),
                    const SizedBox(height: 32),
                    _buildFeatureCardsGrid(context, viewModel),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySection(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viewModel.todayLabel,
          style: AppTypography.leagueSpartanBoldBlack57_64_0,
        ),
        const SizedBox(height: 8),
        DateDisplayWidget(
          formattedDate: viewModel.formattedDate,
        ),
      ],
    );
  }

  Widget _buildFeatureCardsGrid(BuildContext context, HomeViewModel viewModel) {
    final cards = viewModel.featureCards;

    return Column(
      children: cards.map((card) {
        return FeatureCardWidget(
          title: card.title,
          description: card.description,
          imagePath: card.iconPath,
          onTap: () => viewModel.navigateToFeature(context, card.route),
        );
      }).toList(),
    );
  }
}
