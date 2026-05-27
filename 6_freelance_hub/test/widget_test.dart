import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:freelance_hub/main.dart';

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
}
