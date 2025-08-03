import 'package:flutter/material.dart';
import '../../presentation/views/home/home_screen.dart';
import '../../presentation/views/quote_generation/quote_generation_screen.dart';
import '../../presentation/views/quote_generation/step_one_screen.dart';
import '../../presentation/views/quote_generation/step_two_screen.dart';
import '../../presentation/views/quote_generation/step_three_screen.dart';
import '../../presentation/views/quote_generation/calculation_results_screen.dart';
import '../../presentation/views/quote_generation/add_row_screen.dart';
import '../../presentation/views/presets/preset_list_screen.dart';
import '../../presentation/views/presets/preset_detail_screen.dart';

import '../../presentation/views/settings/settings_screen.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String quoteGeneration = '/quote-generation';
  static const String stepOne = '/quote-generation/step-one';
  static const String stepTwo = '/quote-generation/step-two';
  static const String stepThree = '/quote-generation/step-three';
  static const String calculationResults = '/calculation-results';
  static const String addRow = '/add-row';
  static const String presetList = '/presets';
  static const String presetDetail = '/preset-detail';

  static const String settings = '/settings';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case quoteGeneration:
        return MaterialPageRoute(builder: (_) => const QuoteGenerationScreen());

      case stepOne:
        return MaterialPageRoute(builder: (_) => const StepOneScreen());

      case stepTwo:
        return MaterialPageRoute(builder: (_) => const StepTwoScreen());

      case stepThree:
        return MaterialPageRoute(builder: (_) => const StepThreeScreen());

      case calculationResults:
        return MaterialPageRoute(
          builder: (_) => const CalculationResultsScreen(),
        );

      case addRow:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddRowScreen(
            existingRow: args?['existingRow'],
            isEditing: args?['isEditing'] ?? false,
          ),
        );

      case presetList:
        return MaterialPageRoute(builder: (_) => const PresetListScreen());

      case presetDetail:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PresetDetailScreen(
            preset: args?['preset'],
          ),
        );

      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text('No route defined for ${routeSettings.name}')),
          ),
        );
    }
  }
}
