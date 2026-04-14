import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class UpdateTodo implements UseCase<void, TodoEntity> {
  final TodoRepository repository;

  UpdateTodo(this.repository);

  @override
  Future<void> call(TodoEntity params) async {
    return await repository.updateTodo(params);
  }
}
