import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:freelance_hub/main.dart';

void main() {
  testWidgets('App starts on blank HomeView', (WidgetTester tester) async {
    await tester.pumpWidget(const FreelanceHubApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
