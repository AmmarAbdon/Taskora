import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';

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
}
