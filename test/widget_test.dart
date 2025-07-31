// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:solarize/app/app.dart';
import 'package:solarize/core/services/local_storage_service.dart';
import 'package:solarize/data/repositories/quote_repository.dart';
import 'package:solarize/data/repositories/preset_repository.dart';
import 'package:solarize/data/repositories/settings_repository.dart';
import 'package:solarize/presentation/viewmodels/home_viewmodel.dart';
import 'package:solarize/presentation/viewmodels/quote_generation_viewmodel.dart';
import 'package:solarize/presentation/viewmodels/preset_viewmodel.dart';
import 'package:solarize/presentation/viewmodels/settings_viewmodel.dart';

void main() {
  testWidgets('Solarize app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Repositories
          Provider<QuoteRepository>(
              create: (_) => QuoteRepository(LocalStorageService())),
          Provider<PresetRepository>(
              create: (_) => PresetRepository(LocalStorageService())),
          Provider<SettingsRepository>(
              create: (_) => SettingsRepository(LocalStorageService())),

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
          ChangeNotifierProvider<SettingsViewModel>(
            create: (context) =>
                SettingsViewModel(context.read<SettingsRepository>()),
          ),
        ],
        child: const SolarizeApp(),
      ),
    );

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
