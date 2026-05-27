import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:freelance_hub/main.dart';
import 'package:freelance_hub/views/login_view.dart';
import 'package:freelance_hub/views/onboarding_view.dart';
import 'package:freelance_hub/views/signup_view.dart';

void main() {
  testWidgets('App starts on SplashView with brand', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FreelanceHubApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('FreelanceHub'), findsOneWidget);
    expect(find.text('Conecte. Crie. Cresça.'), findsOneWidget);
    expect(find.text('V1.0.0'), findsOneWidget);

    // Drena timers pendentes para evitar pumpAndSettle infinito por causa do
    // AnimationController em repeat + Future.delayed de 3s na SplashView.
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('OnboardingView builds without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: OnboardingView()),
    );

    expect(find.text('Encontre o talento certo'), findsOneWidget);
    expect(find.text('Próximo'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);
    expect(find.text('PT'), findsOneWidget);
  });

  testWidgets('LoginView builds without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginView()),
    );

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entre na sua conta'), findsOneWidget);
    expect(find.text('PLATAFORMA PRO'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
  });

  testWidgets('SignupView builds with role selector and form', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignupView()),
    );

    expect(find.text('Crie sua conta'), findsOneWidget);
    expect(find.text('Eu sou:'), findsOneWidget);
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Freelancer'), findsOneWidget);
    // "Criar conta" aparece 2x: no top bar (título) e no botão primário.
    expect(find.text('Criar conta'), findsNWidgets(2));
  });
}
