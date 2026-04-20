import 'package:intl/intl.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';
import '../models/focus_session_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TodoEntity>> getTodos() async {
    return await localDataSource.getTodos();
  }

  @override
  Future<void> addTodo(TodoEntity todo) async {
    await localDataSource.addTodo(TodoModel.fromEntity(todo));
  }

  @override
  Future<void> updateTodo(TodoEntity todo) async {
    await localDataSource.updateTodo(TodoModel.fromEntity(todo));
  }

  @override
  Future<void> deleteTodo(int id) async {
    await localDataSource.deleteTodo(id);
  }

  @override
  Future<void> completeFocusSession(int duration) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await localDataSource.addFocusSession(FocusSessionModel(date: date, duration: duration));
  }

  @override
  Future<int> getFocusSessionsCountForDay(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return await localDataSource.getFocusSessionsCountForDay(dateStr);
  }
}
