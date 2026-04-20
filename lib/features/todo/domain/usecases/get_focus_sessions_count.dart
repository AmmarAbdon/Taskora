import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

class GetFocusSessionsCount implements UseCase<int, DateTime> {
  final TodoRepository repository;

  GetFocusSessionsCount(this.repository);

  @override
  Future<int> call(DateTime params) async {
    return await repository.getFocusSessionsCountForDay(params);
  }
}
