import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para armazenar a conclusão de um hábito em uma data específica
class HabitCompletion {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;

  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
  });

  /// Cria uma cópia com campos atualizados
  HabitCompletion copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'userId': userId,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  /// Cria a partir de um Map do Firestore
  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'] as String,
      habitId: map['habitId'] as String,
      userId: map['userId'] as String,
      completedAt: (map['completedAt'] as Timestamp).toDate(),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() => toMap();

  /// Cria a partir de JSON
  factory HabitCompletion.fromJson(Map<String, dynamic> json) =>
      HabitCompletion.fromMap(json);

  /// Verifica se a conclusão é do dia especificado
  bool isFromDate(DateTime date) {
    return completedAt.year == date.year &&
        completedAt.month == date.month &&
        completedAt.day == date.day;
  }

  @override
  String toString() {
    return 'HabitCompletion(id: $id, habitId: $habitId, userId: $userId, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HabitCompletion &&
        other.id == id &&
        other.habitId == habitId &&
        other.userId == userId &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        habitId.hashCode ^
        userId.hashCode ^
        completedAt.hashCode;
  }
}

/// Importar esta classe no arquivo do DateFormat
class DateFormat {
  static String format(String pattern, DateTime date) {
    // Implementação básica - pode usar intl package
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
