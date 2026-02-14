import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
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
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get userId => _auth.currentUser?.uid;

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
        isCompleted: false,
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

  /// Marca/desmarca um hábito como completo
  Future<bool> toggleHabitCompletion(String habitId) async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        throw Exception('Habit not found');
      }

      final habit = _habits[habitIndex];
      final updatedHabit = habit.copyWith(isCompleted: !habit.isCompleted);

      // Atualiza no Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .update({'isCompleted': updatedHabit.isCompleted});

      // Atualiza na lista local
      _habits[habitIndex] = updatedHabit;
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
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
