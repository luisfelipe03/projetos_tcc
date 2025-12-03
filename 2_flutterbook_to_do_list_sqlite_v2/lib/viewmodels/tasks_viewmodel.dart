import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_helper.dart';

class TasksViewModel extends ChangeNotifier {
  final List<Task> _tasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  TasksViewModel() {
    _loadFromDb();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> _loadFromDb() async {
    final items = await _dbHelper.getAllTasks();
    _tasks.clear();
    _tasks.addAll(items);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _dbHelper.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(String id, Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      await _dbHelper.updateTask(updatedTask);
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await _dbHelper.deleteTask(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
}
