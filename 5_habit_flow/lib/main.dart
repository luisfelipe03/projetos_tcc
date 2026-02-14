import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:habit_flow/viewmodels/auth_viewmodel.dart';
import 'package:habit_flow/views/onboarding_view.dart';
import 'package:habit_flow/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicializa o serviço de notificações
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const HabitFlowApp());
}

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        title: 'Habit Flow',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.light,
        home: const OnboardingView(),
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
