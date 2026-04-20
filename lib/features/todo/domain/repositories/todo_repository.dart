import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodos();
  Future<void> addTodo(TodoEntity todo);
  Future<void> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(int id);
  
  // Focus Session
  Future<void> completeFocusSession(int duration);
  Future<int> getFocusSessionsCountForDay(DateTime date);
}
