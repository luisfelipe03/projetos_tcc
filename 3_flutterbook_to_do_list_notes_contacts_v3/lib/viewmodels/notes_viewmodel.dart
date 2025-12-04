import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/database_helper.dart';

class NotesViewModel extends ChangeNotifier {
  final List<Note> _notes = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  NotesViewModel() {
    _loadFromDb();
  }

  List<Note> get notes => List.unmodifiable(_notes);

  Future<void> _loadFromDb() async {
    final items = await _dbHelper.getAllNotes();
    _notes.clear();
    _notes.addAll(items);
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _dbHelper.insertNote(note);
    _notes.add(note);
    notifyListeners();
  }

  Future<void> updateNote(String id, Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      await _dbHelper.updateNote(updatedNote);
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await _dbHelper.deleteNote(id);
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}
