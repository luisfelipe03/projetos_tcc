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
  final Map<String, List<HabitCompletion>> _completionsByDate = {};
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get userId => _auth.currentUser?.uid;

  /// Retorna os hábitos que devem aparecer em uma data específica
  List<Habit> getHabitsForDate(DateTime date) {
    return _habits.where((habit) => habit.shouldShowOnDate(date)).toList();
  }

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
    // Filtra apenas os hábitos que deveriam aparecer nesta data
    final validHabitIds = getHabitsForDate(date).map((h) => h.id).toSet();
    return completions.where((c) => validHabitIds.contains(c.habitId)).length;
  }

  /// Obtém todas as conclusões de um hábito específico
  Future<List<HabitCompletion>> getHabitCompletions(String habitId) async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('habitCompletions')
          .where('userId', isEqualTo: userId)
          .where('habitId', isEqualTo: habitId)
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HabitCompletion.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Calcula a sequência atual de dias consecutivos de um hábito
  int getCurrentStreak(List<HabitCompletion> completions, Habit habit) {
    if (completions.isEmpty) return 0;

    completions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    int streak = 0;
    DateTime checkDate = DateTime.now();
    final today = DateTime(checkDate.year, checkDate.month, checkDate.day);

    // Verifica se o hábito deveria ser feito hoje
    if (habit.shouldShowOnDate(today)) {
      final completedToday = completions.any(
        (c) =>
            c.completedAt.year == today.year &&
            c.completedAt.month == today.month &&
            c.completedAt.day == today.day,
      );

      if (completedToday) {
        streak = 1;
        checkDate = today.subtract(const Duration(days: 1));
      } else {
        // Se não foi completado hoje, a streak é 0
        return 0;
      }
    } else {
      // Se não deveria ser feito hoje, começa verificando de ontem
      checkDate = today.subtract(const Duration(days: 1));
    }

    // Verifica dias anteriores
    while (true) {
      final normalizedCheck = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );

      // Para se chegou em data anterior à criação do hábito
      if (!habit.shouldShowOnDate(normalizedCheck)) {
        break;
      }

      // Verifica se foi completado neste dia
      final completedOnDate = completions.any(
        (c) =>
            c.completedAt.year == normalizedCheck.year &&
            c.completedAt.month == normalizedCheck.month &&
            c.completedAt.day == normalizedCheck.day,
      );

      if (completedOnDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calcula o melhor streak de um hábito
  int getBestStreak(List<HabitCompletion> completions, Habit habit) {
    if (completions.isEmpty) return 0;

    completions.sort((a, b) => a.completedAt.compareTo(b.completedAt));

    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (var completion in completions) {
      final completionDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );

      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDiff = completionDate.difference(lastDate).inDays;

        if (daysDiff == 1) {
          currentStreak++;
        } else {
          bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
          currentStreak = 1;
        }
      }

      lastDate = completionDate;
    }

    return currentStreak > bestStreak ? currentStreak : bestStreak;
  }

  /// Calcula a taxa de conclusão mensal
  double getMonthlyCompletionRate(
    List<HabitCompletion> completions,
    Habit habit,
    DateTime month,
  ) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    int totalDays = 0;
    int completedDays = 0;

    for (
      var day = firstDay;
      day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay);
      day = day.add(const Duration(days: 1))
    ) {
      if (habit.shouldShowOnDate(day) && !day.isAfter(DateTime.now())) {
        totalDays++;

        final wasCompleted = completions.any(
          (c) =>
              c.completedAt.year == day.year &&
              c.completedAt.month == day.month &&
              c.completedAt.day == day.day,
        );

        if (wasCompleted) completedDays++;
      }
    }

    return totalDays == 0 ? 0 : (completedDays / totalDays);
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
    List<int>? selectedWeekDays,
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
        selectedWeekDays: selectedWeekDays,
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
