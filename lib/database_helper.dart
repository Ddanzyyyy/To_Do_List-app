import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/task.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static const String tableName = 'tasks';
  static const int databaseVersion = 3; // Naikkan versi database untuk migrasi

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT, // Tambah kolom description
        priority TEXT,
        dueDate TEXT,
        isCompleted INTEGER,
        priorityColor TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN priorityColor TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN description TEXT');
    }
  }

  Color stringToColor(String colorString) {
    return Color(int.parse(colorString.replaceFirst('#', '0xff')));
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    
    print('Maps: $maps'); // Debug print

    return List.generate(maps.length, (i) {
      print('Task: ${maps[i]}'); // Debug print
      
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'] ?? '', // Handle null description
        priority: maps[i]['priority'],
        dueDate: DateTime.parse(maps[i]['dueDate']),
        isCompleted: maps[i]['isCompleted'] == 1,
        priorityColor: maps[i]['priorityColor'] != null 
            ? stringToColor(maps[i]['priorityColor']) 
            : Colors.grey,
      );
    });
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(
      tableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}