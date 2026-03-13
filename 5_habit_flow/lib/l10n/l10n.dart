import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

import '../models/day_of_week.dart';
import '../models/habit_category.dart';
import '../models/habit_frequency.dart';

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension HabitCategoryLocalization on HabitCategory {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case HabitCategory.health:
        return l10n.categoryHealth;
      case HabitCategory.personal:
        return l10n.categoryPersonal;
      case HabitCategory.study:
        return l10n.categoryStudy;
      case HabitCategory.social:
        return l10n.categorySocial;
      case HabitCategory.finance:
        return l10n.categoryFinance;
    }
  }
}

extension HabitFrequencyLocalization on HabitFrequency {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case HabitFrequency.daily:
        return l10n.frequencyDaily;
      case HabitFrequency.weekly:
        return l10n.frequencyWeekly;
      case HabitFrequency.monthly:
        return l10n.frequencyMonthly;
    }
  }
}

extension DayOfWeekLocalization on DayOfWeek {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case DayOfWeek.monday:
        return l10n.dayMonday;
      case DayOfWeek.tuesday:
        return l10n.dayTuesday;
      case DayOfWeek.wednesday:
        return l10n.dayWednesday;
      case DayOfWeek.thursday:
        return l10n.dayThursday;
      case DayOfWeek.friday:
        return l10n.dayFriday;
      case DayOfWeek.saturday:
        return l10n.daySaturday;
      case DayOfWeek.sunday:
        return l10n.daySunday;
    }
  }

  String localizedShortLabel(AppLocalizations l10n) {
    switch (this) {
      case DayOfWeek.monday:
        return l10n.dayShortMonday;
      case DayOfWeek.tuesday:
        return l10n.dayShortTuesday;
      case DayOfWeek.wednesday:
        return l10n.dayShortWednesday;
      case DayOfWeek.thursday:
        return l10n.dayShortThursday;
      case DayOfWeek.friday:
        return l10n.dayShortFriday;
      case DayOfWeek.saturday:
        return l10n.dayShortSaturday;
      case DayOfWeek.sunday:
        return l10n.dayShortSunday;
    }
  }
}