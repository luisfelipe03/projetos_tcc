import 'package:flutter/material.dart';

enum HabitColor {
  red,
  blue,
  green,
  purple,
  orange;

  Color get color {
    switch (this) {
      case HabitColor.red:
        return const Color(0xFFEF4444);
      case HabitColor.blue:
        return const Color(0xFF3B82F6);
      case HabitColor.green:
        return const Color(0xFF10B981);
      case HabitColor.purple:
        return const Color(0xFF8B5CF6);
      case HabitColor.orange:
        return const Color(0xFFF97316);
    }
  }

  String get displayName {
    switch (this) {
      case HabitColor.red:
        return 'Red';
      case HabitColor.blue:
        return 'Blue';
      case HabitColor.green:
        return 'Green';
      case HabitColor.purple:
        return 'Purple';
      case HabitColor.orange:
        return 'Orange';
    }
  }

  static HabitColor fromString(String value) {
    switch (value.toLowerCase()) {
      case 'red':
        return HabitColor.red;
      case 'blue':
        return HabitColor.blue;
      case 'green':
        return HabitColor.green;
      case 'purple':
        return HabitColor.purple;
      case 'orange':
        return HabitColor.orange;
      default:
        throw ArgumentError('Invalid color: $value');
    }
  }
}
