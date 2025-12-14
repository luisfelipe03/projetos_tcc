import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/note_model.dart';
import '../models/contact_model.dart';
import '../models/appointment_model.dart';

class DatabaseHelper {
  static const _databaseName = 'flutterbook.db';
  static const _databaseVersion = 4;

  static const tableTasks = 'tasks';
  static const tableNotes = 'notes';
  static const tableContacts = 'contacts';
  static const tableAppointments = 'appointments';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTasks (
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        dueDate INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableNotes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableContacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        avatarPath TEXT,
        birthday INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAppointments (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date INTEGER NOT NULL
      )
    ''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $tableNotes (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          color TEXT NOT NULL,
          createdAt INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $tableContacts (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT NOT NULL,
          avatarPath TEXT,
          birthday INTEGER
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE $tableAppointments (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          date INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query(tableTasks, orderBy: 'dueDate ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      tableTasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(tableTasks, where: 'id = ?', whereArgs: [id]);
  }

  // Notes CRUD operations
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(tableNotes, orderBy: 'createdAt DESC');
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      tableNotes,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete(tableNotes, where: 'id = ?', whereArgs: [id]);
  }

  // Contacts CRUD operations
  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final maps = await db.query(tableContacts, orderBy: 'name ASC');
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert(
      tableContacts,
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      tableContacts,
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(String id) async {
    final db = await database;
    await db.delete(tableContacts, where: 'id = ?', whereArgs: [id]);
  }

  // Appointments CRUD operations
  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final maps = await db.query(tableAppointments, orderBy: 'date ASC');
    return maps.map((m) => Appointment.fromMap(m)).toList();
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final maps = await db.query(
      tableAppointments,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'date ASC',
    );
    return maps.map((m) => Appointment.fromMap(m)).toList();
  }

  Future<void> insertAppointment(Appointment appointment) async {
    final db = await database;
    await db.insert(
      tableAppointments,
      appointment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final db = await database;
    await db.update(
      tableAppointments,
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<void> deleteAppointment(String id) async {
    final db = await database;
    await db.delete(tableAppointments, where: 'id = ?', whereArgs: [id]);
  }
}
