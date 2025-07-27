import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/services/local_storage_service.dart';
import 'data/repositories/quote_repository.dart';
import 'data/repositories/preset_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/quote_generation_viewmodel.dart';
import 'presentation/viewmodels/preset_viewmodel.dart';
import 'presentation/viewmodels/calculator_viewmodel.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage service
  await LocalStorageService.init();

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        Provider<QuoteRepository>(create: (_) => QuoteRepository()),
        Provider<PresetRepository>(create: (_) => PresetRepository()),
        Provider<SettingsRepository>(create: (_) => SettingsRepository()),

        // ViewModels
        ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
        ChangeNotifierProvider<QuoteGenerationViewModel>(
          create: (context) =>
              QuoteGenerationViewModel(context.read<QuoteRepository>()),
        ),
        ChangeNotifierProvider<PresetViewModel>(
          create: (context) =>
              PresetViewModel(context.read<PresetRepository>()),
        ),
        ChangeNotifierProvider<CalculatorViewModel>(
          create: (_) => CalculatorViewModel(),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) =>
              SettingsViewModel(context.read<SettingsRepository>()),
        ),
      ],
      child: const SolarizeApp(),
    ),
  );
}
