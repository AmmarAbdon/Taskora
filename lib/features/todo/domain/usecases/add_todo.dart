import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class AddTodo implements UseCase<void, TodoEntity> {
  final TodoRepository repository;

  AddTodo(this.repository);

  @override
  Future<void> call(TodoEntity params) async {
    return await repository.addTodo(params);
  }
}
