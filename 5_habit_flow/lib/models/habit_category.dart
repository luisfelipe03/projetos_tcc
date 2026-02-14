enum HabitCategory {
  health,
  personal,
  study,
  social,
  finance;

  String get displayName {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.personal:
        return 'Personal';
      case HabitCategory.study:
        return 'Study';
      case HabitCategory.social:
        return 'Social';
      case HabitCategory.finance:
        return 'Finance';
    }
  }

  static HabitCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'health':
        return HabitCategory.health;
      case 'personal':
        return HabitCategory.personal;
      case 'study':
        return HabitCategory.study;
      case 'social':
        return HabitCategory.social;
      case 'finance':
        return HabitCategory.finance;
      default:
        throw ArgumentError('Invalid category: $value');
    }
  }
}
