enum HabitFrequency {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }

  static HabitFrequency fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return HabitFrequency.daily;
      case 'weekly':
        return HabitFrequency.weekly;
      case 'monthly':
        return HabitFrequency.monthly;
      default:
        throw ArgumentError('Invalid frequency: $value');
    }
  }
}
