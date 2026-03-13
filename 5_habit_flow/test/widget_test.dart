import 'package:flutter_test/flutter_test.dart';

import 'package:habit_flow/main.dart';
import 'package:habit_flow/viewmodels/settings_viewmodel.dart';

void main() {
  test('HabitFlowApp can be instantiated', () {
    final app = HabitFlowApp(settingsViewModel: SettingsViewModel());
    expect(app, isNotNull);
  });
}
