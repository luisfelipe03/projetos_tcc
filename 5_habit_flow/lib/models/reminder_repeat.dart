enum ReminderRepeat {
  none,
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case ReminderRepeat.none:
        return 'None';
      case ReminderRepeat.daily:
        return 'Daily';
      case ReminderRepeat.weekly:
        return 'Weekly';
      case ReminderRepeat.monthly:
        return 'Monthly';
    }
  }

  static ReminderRepeat fromString(String value) {
    switch (value.toLowerCase()) {
      case 'none':
        return ReminderRepeat.none;
      case 'daily':
        return ReminderRepeat.daily;
      case 'weekly':
        return ReminderRepeat.weekly;
      case 'monthly':
        return ReminderRepeat.monthly;
      default:
        throw ArgumentError('Invalid reminder repeat: $value');
    }
  }
}
