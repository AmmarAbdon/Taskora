import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetTodos implements UseCase<List<TodoEntity>, NoParams> {
  final TodoRepository repository;

  GetTodos(this.repository);

  @override
  Future<List<TodoEntity>> call(NoParams params) async {
    return await repository.getTodos();
  }
}
