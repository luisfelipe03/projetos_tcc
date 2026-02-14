import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit_frequency.dart';
import 'habit_category.dart';
import 'habit_color.dart';

class Habit {
  final String id;
  final String title;
  final HabitFrequency frequency;
  final HabitCategory category;
  final DateTime? reminderTime;
  final HabitColor habitColor;
  final DateTime createdAt;
  final bool isCompleted;

  Habit({
    required this.id,
    required this.title,
    required this.frequency,
    required this.category,
    this.reminderTime,
    required this.habitColor,
    required this.createdAt,
    this.isCompleted = false,
  });

  /// Cria uma cópia do hábito com campos atualizados
  Habit copyWith({
    String? id,
    String? title,
    HabitFrequency? frequency,
    HabitCategory? category,
    DateTime? reminderTime,
    HabitColor? habitColor,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      reminderTime: reminderTime ?? this.reminderTime,
      habitColor: habitColor ?? this.habitColor,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Converte o modelo para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'frequency': frequency.name,
      'category': category.name,
      'reminderTime': reminderTime != null
          ? Timestamp.fromDate(reminderTime!)
          : null,
      'habitColor': habitColor.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
    };
  }

  /// Cria um modelo a partir de um Map do Firestore
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      frequency: HabitFrequency.fromString(map['frequency'] as String),
      category: HabitCategory.fromString(map['category'] as String),
      reminderTime: map['reminderTime'] != null
          ? (map['reminderTime'] as Timestamp).toDate()
          : null,
      habitColor: HabitColor.fromString(map['habitColor'] as String),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  /// Cria um modelo a partir de um DocumentSnapshot do Firestore
  factory Habit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Habit.fromMap(data);
  }

  /// Converte para JSON (útil para debug)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'frequency': frequency.name,
      'category': category.name,
      'reminderTime': reminderTime?.toIso8601String(),
      'habitColor': habitColor.name,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, frequency: ${frequency.name}, '
        'category: ${category.name}, habitColor: ${habitColor.name}, '
        'isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Habit &&
        other.id == id &&
        other.title == title &&
        other.frequency == frequency &&
        other.category == category &&
        other.reminderTime == reminderTime &&
        other.habitColor == habitColor &&
        other.createdAt == createdAt &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        frequency.hashCode ^
        category.hashCode ^
        reminderTime.hashCode ^
        habitColor.hashCode ^
        createdAt.hashCode ^
        isCompleted.hashCode;
  }
}
