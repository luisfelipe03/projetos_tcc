import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/habit_frequency.dart';
import '../models/habit_category.dart';
import '../models/habit_color.dart';
import '../models/habit_reminder.dart';
import '../services/notification_service.dart';

class HabitSeedResult {
  final int habitsCreated;
  final int completionsCreated;
  final bool clearedExistingData;

  const HabitSeedResult({
    required this.habitsCreated,
    required this.completionsCreated,
    required this.clearedExistingData,
  });
}

class _SeedHabitTemplate {
  final String title;
  final HabitFrequency frequency;
  final HabitCategory category;
  final HabitColor color;
  final int createdDaysAgo;
  final double completionRate;
  final List<int> selectedWeekDays;
  final int recentStreakDays;

  const _SeedHabitTemplate({
    required this.title,
    required this.frequency,
    required this.category,
    required this.color,
    required this.createdDaysAgo,
    required this.completionRate,
    this.selectedWeekDays = const [],
    this.recentStreakDays = 0,
  });
}

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

  bool _isMissingIndexError(Object error) {
    if (error is! FirebaseException) {
      return false;
    }

    final message = error.message?.toLowerCase() ?? '';
    return error.code == 'failed-precondition' && message.contains('index');
  }

  Future<List<HabitCompletion>> _getAllUserCompletions() async {
    final uid = userId;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final querySnapshot = await _firestore
        .collection('habitCompletions')
        .where('userId', isEqualTo: uid)
        .get();

    return querySnapshot.docs
        .map((doc) => HabitCompletion.fromMap(doc.data()))
        .toList();
  }

  bool _isCompletionInRange(
    HabitCompletion completion,
    DateTime startInclusive,
    DateTime endExclusive,
  ) {
    final completionDate = _normalizeDate(completion.completedAt);
    return !completionDate.isBefore(startInclusive) &&
        completionDate.isBefore(endExclusive);
  }

  /// Busca um hábito específico por ID
  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((habit) => habit.id == habitId);
    } catch (e) {
      return null;
    }
  }

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

      try {
        final querySnapshot = await _firestore
            .collection('habitCompletions')
            .where('userId', isEqualTo: userId)
            .where('habitId', isEqualTo: habitId)
            .orderBy('completedAt', descending: true)
            .get();

        return querySnapshot.docs
            .map((doc) => HabitCompletion.fromMap(doc.data()))
            .toList();
      } on FirebaseException catch (e) {
        if (!_isMissingIndexError(e)) {
          rethrow;
        }

        debugPrint(
          'Missing index for getHabitCompletions; using client-side filter fallback.',
        );

        final completions = await _getAllUserCompletions();
        final filtered =
            completions
                .where((completion) => completion.habitId == habitId)
                .toList()
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

        return filtered;
      }
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

      // Encontra o hábito existente
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        throw Exception('Habit not found');
      }

      final existingHabit = _habits[habitIndex];

      // Cria o hábito atualizado (mantém createdAt original)
      final updatedHabit = Habit(
        id: habitId,
        title: title.trim(),
        frequency: frequency,
        category: category,
        habitColor: habitColor,
        reminder: reminder,
        createdAt: existingHabit.createdAt, // Mantém data de criação original
        selectedWeekDays: selectedWeekDays,
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

      // Cria novas notificações se houver reminder
      if (reminder != null) {
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

      List<HabitCompletion> completions;

      try {
        final querySnapshot = await _firestore
            .collection('habitCompletions')
            .where('userId', isEqualTo: userId)
            .where(
              'completedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
            .get();

        completions = querySnapshot.docs
            .map((doc) => HabitCompletion.fromMap(doc.data()))
            .toList();
      } on FirebaseException catch (e) {
        if (!_isMissingIndexError(e)) {
          rethrow;
        }

        debugPrint(
          'Missing index for loadCompletionsForDate; using client-side filter fallback.',
        );

        final allCompletions = await _getAllUserCompletions();
        completions = allCompletions
            .where(
              (completion) => _isCompletionInRange(
                completion,
                normalizedDate,
                normalizedDate.add(const Duration(days: 1)),
              ),
            )
            .toList();
      }

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

      List<HabitCompletion> completions;

      try {
        final querySnapshot = await _firestore
            .collection('habitCompletions')
            .where('userId', isEqualTo: userId)
            .where(
              'completedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart),
            )
            .where('completedAt', isLessThan: Timestamp.fromDate(normalizedEnd))
            .get();

        completions = querySnapshot.docs
            .map((doc) => HabitCompletion.fromMap(doc.data()))
            .toList();
      } on FirebaseException catch (e) {
        if (!_isMissingIndexError(e)) {
          rethrow;
        }

        debugPrint(
          'Missing index for loadCompletionsForDateRange; using client-side filter fallback.',
        );

        final allCompletions = await _getAllUserCompletions();
        completions = allCompletions
            .where(
              (completion) => _isCompletionInRange(
                completion,
                normalizedStart,
                normalizedEnd,
              ),
            )
            .toList();
      }

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

  /// Busca todas as conclusões do usuário em um intervalo de datas
  Future<List<HabitCompletion>> getCompletionsInRange(
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

      try {
        final querySnapshot = await _firestore
            .collection('habitCompletions')
            .where('userId', isEqualTo: userId)
            .where(
              'completedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart),
            )
            .where('completedAt', isLessThan: Timestamp.fromDate(normalizedEnd))
            .get();

        return querySnapshot.docs
            .map((doc) => HabitCompletion.fromMap(doc.data()))
            .toList();
      } on FirebaseException catch (e) {
        if (!_isMissingIndexError(e)) {
          rethrow;
        }

        debugPrint(
          'Missing index for getCompletionsInRange; using client-side filter fallback.',
        );

        final allCompletions = await _getAllUserCompletions();
        return allCompletions
            .where(
              (completion) => _isCompletionInRange(
                completion,
                normalizedStart,
                normalizedEnd,
              ),
            )
            .toList();
      }
    } catch (e) {
      _setError(e.toString());
      return [];
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

  /// Popula o banco com dados sintéticos para testes de UI/estatísticas.
  Future<HabitSeedResult> seedFakeDataForDevelopment({
    bool clearExistingData = true,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final uid = userId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      if (clearExistingData) {
        await _clearUserSeedData(uid);
      }

      final today = _normalizeDate(DateTime.now());
      final templates = _buildSeedTemplates();

      final habitsCollection = _firestore
          .collection('users')
          .doc(uid)
          .collection('habits');

      final createdHabits = <Habit>[];
      final habitBatch = _firestore.batch();

      for (final template in templates) {
        final createdAt = today.subtract(
          Duration(days: template.createdDaysAgo),
        );
        final habit = Habit(
          id: _uuid.v4(),
          title: template.title,
          frequency: template.frequency,
          category: template.category,
          habitColor: template.color,
          reminder: null,
          createdAt: createdAt,
          selectedWeekDays: template.selectedWeekDays,
        );

        habitBatch.set(habitsCollection.doc(habit.id), habit.toMap());
        createdHabits.add(habit);
      }

      await habitBatch.commit();

      final completionsCollection = _firestore.collection('habitCompletions');
      final completionDocs = <Map<String, dynamic>>[];

      for (var i = 0; i < createdHabits.length; i++) {
        final habit = createdHabits[i];
        final template = templates[i];

        for (
          var day = _normalizeDate(habit.createdAt);
          !day.isAfter(today);
          day = day.add(const Duration(days: 1))
        ) {
          if (!habit.shouldShowOnDate(day)) {
            continue;
          }

          final withinRecentStreak =
              template.recentStreakDays > 0 &&
              day.isAfter(
                today.subtract(Duration(days: template.recentStreakDays)),
              );

          final shouldComplete = withinRecentStreak
              ? true
              : _seedCompletionDecision(
                  habitId: habit.id,
                  date: day,
                  completionRate: template.completionRate,
                );

          if (!shouldComplete) {
            continue;
          }

          final completion = HabitCompletion(
            id: _uuid.v4(),
            habitId: habit.id,
            userId: uid,
            completedAt: day,
          );

          completionDocs.add(completion.toMap());
        }
      }

      await _insertCompletionDocsInBatches(
        completionDocs,
        completionsCollection,
      );

      await loadHabits();
      await loadCompletionsForDate(today);

      _setLoading(false);
      return HabitSeedResult(
        habitsCreated: createdHabits.length,
        completionsCreated: completionDocs.length,
        clearedExistingData: clearExistingData,
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  List<_SeedHabitTemplate> _buildSeedTemplates() {
    return const [
      _SeedHabitTemplate(
        title: 'Drink 2L of water',
        frequency: HabitFrequency.daily,
        category: HabitCategory.health,
        color: HabitColor.blue,
        createdDaysAgo: 90,
        completionRate: 0.92,
        recentStreakDays: 14,
      ),
      _SeedHabitTemplate(
        title: 'Morning meditation',
        frequency: HabitFrequency.daily,
        category: HabitCategory.personal,
        color: HabitColor.green,
        createdDaysAgo: 60,
        completionRate: 0.78,
        recentStreakDays: 9,
      ),
      _SeedHabitTemplate(
        title: 'Workout routine',
        frequency: HabitFrequency.weekly,
        category: HabitCategory.health,
        color: HabitColor.red,
        createdDaysAgo: 75,
        completionRate: 0.66,
        selectedWeekDays: [1, 3, 5],
      ),
      _SeedHabitTemplate(
        title: 'Study Flutter',
        frequency: HabitFrequency.daily,
        category: HabitCategory.study,
        color: HabitColor.purple,
        createdDaysAgo: 55,
        completionRate: 0.58,
      ),
      _SeedHabitTemplate(
        title: 'Read 20 pages',
        frequency: HabitFrequency.daily,
        category: HabitCategory.study,
        color: HabitColor.orange,
        createdDaysAgo: 45,
        completionRate: 0.37,
      ),
      _SeedHabitTemplate(
        title: 'Review weekly budget',
        frequency: HabitFrequency.weekly,
        category: HabitCategory.finance,
        color: HabitColor.green,
        createdDaysAgo: 85,
        completionRate: 0.52,
        selectedWeekDays: [7],
      ),
      _SeedHabitTemplate(
        title: 'Monthly planning',
        frequency: HabitFrequency.monthly,
        category: HabitCategory.finance,
        color: HabitColor.purple,
        createdDaysAgo: 120,
        completionRate: 0.12,
      ),
      _SeedHabitTemplate(
        title: 'Call family',
        frequency: HabitFrequency.weekly,
        category: HabitCategory.social,
        color: HabitColor.blue,
        createdDaysAgo: 70,
        completionRate: 0.44,
        selectedWeekDays: [2, 6],
      ),
      _SeedHabitTemplate(
        title: 'No sugar day',
        frequency: HabitFrequency.daily,
        category: HabitCategory.health,
        color: HabitColor.orange,
        createdDaysAgo: 25,
        completionRate: 0.21,
      ),
      _SeedHabitTemplate(
        title: 'Evening walk',
        frequency: HabitFrequency.daily,
        category: HabitCategory.personal,
        color: HabitColor.red,
        createdDaysAgo: 18,
        completionRate: 0.0,
      ),
    ];
  }

  bool _seedCompletionDecision({
    required String habitId,
    required DateTime date,
    required double completionRate,
  }) {
    if (completionRate <= 0) {
      return false;
    }
    if (completionRate >= 1) {
      return true;
    }

    final key = '${habitId}_${date.year}_${date.month}_${date.day}';
    final random = math.Random(key.hashCode);
    return random.nextDouble() < completionRate;
  }

  Future<void> _insertCompletionDocsInBatches(
    List<Map<String, dynamic>> completionDocs,
    CollectionReference<Map<String, dynamic>> completionsCollection,
  ) async {
    if (completionDocs.isEmpty) {
      return;
    }

    const batchSize = 400;
    for (var i = 0; i < completionDocs.length; i += batchSize) {
      final end = math.min(i + batchSize, completionDocs.length);
      final batch = _firestore.batch();

      for (final data in completionDocs.sublist(i, end)) {
        final docRef = completionsCollection.doc(data['id'] as String);
        batch.set(docRef, data);
      }

      await batch.commit();
    }
  }

  Future<void> _clearUserSeedData(String uid) async {
    final habitSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .get();

    final completionSnapshot = await _firestore
        .collection('habitCompletions')
        .where('userId', isEqualTo: uid)
        .get();

    await _deleteDocsInBatches(habitSnapshot.docs.map((doc) => doc.reference));
    await _deleteDocsInBatches(
      completionSnapshot.docs.map((doc) => doc.reference),
    );

    await _notificationService.cancelAllNotifications();

    _habits.clear();
    _completionsByDate.clear();
    notifyListeners();
  }

  Future<void> _deleteDocsInBatches(
    Iterable<DocumentReference<Map<String, dynamic>>> refs,
  ) async {
    const batchSize = 400;
    final references = refs.toList();

    for (var i = 0; i < references.length; i += batchSize) {
      final end = math.min(i + batchSize, references.length);
      final batch = _firestore.batch();

      for (final ref in references.sublist(i, end)) {
        batch.delete(ref);
      }

      await batch.commit();
    }
  }
}
