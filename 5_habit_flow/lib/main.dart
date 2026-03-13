import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:habit_flow/viewmodels/auth_viewmodel.dart';
import 'package:habit_flow/viewmodels/habit_viewmodel.dart';
import 'package:habit_flow/viewmodels/settings_viewmodel.dart';
import 'package:habit_flow/views/onboarding_view.dart';
import 'package:habit_flow/views/habits/habit_details_view.dart';
import 'package:habit_flow/services/notification_service.dart';

import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final settingsViewModel = SettingsViewModel();
  await settingsViewModel.loadPreferences();

  // Inicializa o serviço de notificações
  final notificationService = NotificationService();
  await notificationService.initialize();
  if (settingsViewModel.notificationsEnabled) {
    await notificationService.requestPermissions();
  }

  // Configura o callback para navegação de notificações
  notificationService.setOnNotificationTapCallback((habitId) {
    _handleNotificationTap(habitId);
  });

  runApp(HabitFlowApp(settingsViewModel: settingsViewModel));
}

/// Trata o toque em uma notificação navegando para os detalhes do hábito
void _handleNotificationTap(String habitId) {
  final context = navigatorKey.currentContext;
  if (context == null) {
    debugPrint('Navigator context is null');
    return;
  }

  // Busca o hábito usando o HabitViewModel
  final habitViewModel = Provider.of<HabitViewModel>(context, listen: false);
  final habit = habitViewModel.getHabitById(habitId);

  if (habit == null) {
    debugPrint('Habit not found: $habitId');
    return;
  }

  // Navega para a tela de detalhes do hábito
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => HabitDetailsView(habit: habit)),
  );
}

class HabitFlowApp extends StatelessWidget {
  final SettingsViewModel settingsViewModel;

  const HabitFlowApp({super.key, required this.settingsViewModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HabitViewModel()),
        ChangeNotifierProvider<SettingsViewModel>.value(
          value: settingsViewModel,
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const OnboardingView(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8B5CF6),
        secondary: Color(0xFF4F7FFF),
        surface: Color(0xFFF5F5F7),
        onSurface: Color(0xFF1F2937),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8B5CF6),
        secondary: Color(0xFF4F7FFF),
        surface: Color(0xFF1A1625),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1625),
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
    );
  }
}
