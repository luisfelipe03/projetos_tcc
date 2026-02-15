import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/habit_frequency.dart';
import '../models/habit_category.dart';
import '../models/habit_color.dart';
import '../models/habit_reminder.dart';
import '../services/notification_service.dart';

class HabitViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<Habit> _habits = [];
  Map<String, List<HabitCompletion>> _completionsByDate = {};
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get userId => _auth.currentUser?.uid;

  /// Verifica se um hábito está completo em uma data específica
  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    final dateKey = _getDateKey(date);
    final completions = _completionsByDate[dateKey] ?? [];
    return completions.any((c) => c.habitId == habitId);
  }

  /// Obtém o número de hábitos completos em uma data
  int getCompletedCountForDate(DateTime date) {
    final dateKey = _getDateKey(date);
    final completions = _completionsByDate[dateKey] ?? [];
    return completions.length;
  }

  /// Gera uma chave única para a data (yyyy-MM-dd)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Normaliza a data para meia-noite (remove horas, minutos, segundos)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Cria um novo hábito
  Future<bool> createHabit({
    required String title,
    required HabitFrequency frequency,
    required HabitCategory category,
    required HabitColor habitColor,
    HabitReminder? reminder,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Validações
      if (title.trim().isEmpty) {
        throw Exception('Habit title cannot be empty');
      }

      // Cria o hábito
      final habit = Habit(
        id: _uuid.v4(),
        title: title.trim(),
        frequency: frequency,
        category: category,
        habitColor: habitColor,
        reminder: reminder,
        createdAt: DateTime.now(),
      );

      // Salva no Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit.id)
          .set(habit.toMap());

      // Agenda notificação se houver reminder
      if (reminder != null) {
        await _notificationService.scheduleHabitReminder(habit);
      }

      // Adiciona à lista local
      _habits.add(habit);
      notifyListeners();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Atualiza um hábito existente
  Future<bool> updateHabit({
    required String habitId,
    String? title,
    HabitFrequency? frequency,
    HabitCategory? category,
    HabitColor? habitColor,
    HabitReminder? reminder,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Encontra o hábito na lista
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        throw Exception('Habit not found');
      }

      final oldHabit = _habits[habitIndex];

      // Cria o hábito atualizado
      final updatedHabit = oldHabit.copyWith(
        title: title,
        frequency: frequency,
        category: category,
        habitColor: habitColor,
        reminder: reminder,
      );

      // Atualiza no Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .update(updatedHabit.toMap());

      // Cancela notificações antigas
      await _notificationService.cancelHabitReminder(habitId);

      // Agenda novas notificações se houver reminder
      if (updatedHabit.reminder != null) {
        await _notificationService.scheduleHabitReminder(updatedHabit);
      }

      // Atualiza na lista local
      _habits[habitIndex] = updatedHabit;
      notifyListeners();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Deleta um hábito
  Future<bool> deleteHabit(String habitId) async {
    try {
      _setLoading(true);
      _setError(null);

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove do Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .delete();

      // Deleta todas as conclusões deste hábito
      await _deleteHabitCompletions(habitId);

      // Cancela notificações
      await _notificationService.cancelHabitReminder(habitId);

      // Remove da lista local
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Marca/desmarca um hábito como completo em uma data específica
  Future<bool> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final normalizedDate = _normalizeDate(date);
      final dateKey = _getDateKey(normalizedDate);

      // Verifica se já existe uma conclusão para este hábito nesta data
      final existingCompletions = _completionsByDate[dateKey] ?? [];
      final existingCompletion = existingCompletions
          .where((c) => c.habitId == habitId)
          .firstOrNull;

      if (existingCompletion != null) {
        // Se existe, remove (desmarca)
        await _firestore
            .collection('habitCompletions')
            .doc(existingCompletion.id)
            .delete();

        existingCompletions.remove(existingCompletion);
        _completionsByDate[dateKey] = existingCompletions;
      } else {
        // Se não existe, cria (marca como completo)
        final completion = HabitCompletion(
          id: _uuid.v4(),
          habitId: habitId,
          userId: userId!,
          completedAt: normalizedDate,
        );

        await _firestore
            .collection('habitCompletions')
            .doc(completion.id)
            .set(completion.toMap());

        existingCompletions.add(completion);
        _completionsByDate[dateKey] = existingCompletions;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Carrega as conclusões de uma data específica
  Future<void> loadCompletionsForDate(DateTime date) async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final normalizedDate = _normalizeDate(date);
      final dateKey = _getDateKey(normalizedDate);

      // Carrega do Firestore
      final startOfDay = normalizedDate;
      final endOfDay = normalizedDate.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('habitCompletions')
          .where('userId', isEqualTo: userId)
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final completions = querySnapshot.docs
          .map((doc) => HabitCompletion.fromMap(doc.data()))
          .toList();

      _completionsByDate[dateKey] = completions;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Carrega completions para múltiplas datas (útil para calendário)
  Future<void> loadCompletionsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final normalizedStart = _normalizeDate(startDate);
      final normalizedEnd = _normalizeDate(
        endDate,
      ).add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('habitCompletions')
          .where('userId', isEqualTo: userId)
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart),
          )
          .where('completedAt', isLessThan: Timestamp.fromDate(normalizedEnd))
          .get();

      final completions = querySnapshot.docs
          .map((doc) => HabitCompletion.fromMap(doc.data()))
          .toList();

      // Agrupa por data
      _completionsByDate.clear();
      for (var completion in completions) {
        final dateKey = _getDateKey(completion.completedAt);
        if (_completionsByDate[dateKey] == null) {
          _completionsByDate[dateKey] = [];
        }
        _completionsByDate[dateKey]!.add(completion);
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Deleta todas as conclusões de um hábito
  Future<void> _deleteHabitCompletions(String habitId) async {
    try {
      if (userId == null) return;

      final querySnapshot = await _firestore
          .collection('habitCompletions')
          .where('userId', isEqualTo: userId)
          .where('habitId', isEqualTo: habitId)
          .get();

      // Deleta em batch
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Remove do cache local
      _completionsByDate.forEach((key, completions) {
        completions.removeWhere((c) => c.habitId == habitId);
      });
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Carrega todos os hábitos do usuário
  Future<void> loadHabits() async {
    try {
      _setLoading(true);
      _setError(null);

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .orderBy('createdAt', descending: true)
          .get();

      _habits = querySnapshot.docs
          .map((doc) => Habit.fromMap(doc.data()))
          .toList();

      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    if (value != null) {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
