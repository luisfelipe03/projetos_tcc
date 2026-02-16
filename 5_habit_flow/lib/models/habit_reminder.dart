import 'package:flutter/material.dart';
import 'reminder_repeat.dart';
import 'day_of_week.dart';

class HabitReminder {
  final TimeOfDay time;
  final ReminderRepeat repeat;
  final List<DayOfWeek> daysOfWeek;

  HabitReminder({
    required this.time,
    required this.repeat,
    List<DayOfWeek>? daysOfWeek,
  }) : daysOfWeek = daysOfWeek ?? [] {
    // Validação: daysOfWeek só deve ser preenchido se repeat for weekly
    if (repeat == ReminderRepeat.weekly && this.daysOfWeek.isEmpty) {
      throw ArgumentError('daysOfWeek must be provided when repeat is weekly');
    }
    if (repeat != ReminderRepeat.weekly && this.daysOfWeek.isNotEmpty) {
      throw ArgumentError(
        'daysOfWeek should only be provided when repeat is weekly',
      );
    }
  }

  /// Cria uma cópia do reminder com campos atualizados
  HabitReminder copyWith({
    TimeOfDay? time,
    ReminderRepeat? repeat,
    List<DayOfWeek>? daysOfWeek,
  }) {
    return HabitReminder(
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }

  /// Converte o modelo para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'hour': time.hour,
      'minute': time.minute,
      'repeat': repeat.name,
      'daysOfWeek': daysOfWeek.map((day) => day.name).toList(),
    };
  }

  /// Cria um modelo a partir de um Map do Firestore
  factory HabitReminder.fromMap(Map<String, dynamic> map) {
    final hour = map['hour'] as int;
    final minute = map['minute'] as int;
    final repeat = ReminderRepeat.fromString(map['repeat'] as String);
    final daysOfWeekList =
        (map['daysOfWeek'] as List<dynamic>?)
            ?.map((day) => DayOfWeek.fromString(day as String))
            .toList() ??
        [];

    return HabitReminder(
      time: TimeOfDay(hour: hour, minute: minute),
      repeat: repeat,
      daysOfWeek: daysOfWeekList,
    );
  }

  /// Converte TimeOfDay para minutos desde meia-noite
  int get timeInMinutes => time.hour * 60 + time.minute;

  /// Formata o horário para exibição
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Retorna os dias da semana formatados
  String get formattedDaysOfWeek {
    if (daysOfWeek.isEmpty) return '';
    return daysOfWeek.map((day) => day.shortName).join(', ');
  }

  @override
  String toString() {
    return 'HabitReminder(time: $formattedTime, repeat: ${repeat.name}, '
        'daysOfWeek: ${daysOfWeek.map((d) => d.name).toList()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HabitReminder &&
        other.time.hour == time.hour &&
        other.time.minute == time.minute &&
        other.repeat == repeat &&
        _listEquals(other.daysOfWeek, daysOfWeek);
  }

  @override
  int get hashCode {
    return time.hashCode ^ repeat.hashCode ^ daysOfWeek.hashCode;
  }

  bool _listEquals(List<DayOfWeek> list1, List<DayOfWeek> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
