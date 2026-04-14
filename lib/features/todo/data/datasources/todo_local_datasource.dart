import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../core/error/exceptions.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> addTodo(TodoModel todo);
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'todo_database_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            dateTime TEXT,
            isCompleted INTEGER,
            isPinned INTEGER,
            priority TEXT,
            category TEXT,
            notificationId INTEGER
          )
        ''');
      },
    );
  }

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'todos',
        orderBy: 'dateTime ASC',
      );
      return List.generate(maps.length, (i) {
        return TodoModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException(
        'Failed to load tasks from local storage: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    try {
      final db = await database;
      await db.insert(
        'todos',
        todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(
        'Failed to add task to local storage: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    try {
      final db = await database;
      await db.update(
        'todos',
        todo.toJson(),
        where: 'id = ?',
        whereArgs: [todo.id],
      );
    } catch (e) {
      throw CacheException(
        'Failed to update task in local storage: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      final db = await database;
      await db.delete('todos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw CacheException(
        'Failed to delete task from local storage: ${e.toString()}',
      );
    }
  }
}
