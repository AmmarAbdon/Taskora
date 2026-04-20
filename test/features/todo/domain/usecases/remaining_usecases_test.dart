import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';
import 'package:taskora/features/todo/domain/repositories/todo_repository.dart';
import 'package:taskora/features/todo/domain/usecases/delete_todo.dart';
import 'package:taskora/features/todo/domain/usecases/update_todo.dart';
import 'package:taskora/features/todo/domain/usecases/get_focus_sessions_count.dart';

class MockTodoRepository extends Mock implements TodoRepository {}
class FakeTodoEntity extends Fake implements TodoEntity {}

void main() {
  late MockTodoRepository mockRepository;
  late UpdateTodo updateTodo;
  late DeleteTodo deleteTodo;
  late GetFocusSessionsCount getFocusSessionsCount;

  setUpAll(() {
    registerFallbackValue(FakeTodoEntity());
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockRepository = MockTodoRepository();
    updateTodo = UpdateTodo(mockRepository);
    deleteTodo = DeleteTodo(mockRepository);
    getFocusSessionsCount = GetFocusSessionsCount(mockRepository);
  });

  final tTodo = TodoEntity(
    id: 1,
    title: 'Test',
    description: 'Desc',
    dateTime: DateTime(2026),
    priority: TodoPriority.medium,
    category: 'Work',
    notificationId: 101,
  );

  group('Remaining Todo UseCases', () {
    test('UpdateTodo should call repository', () async {
      when(() => mockRepository.updateTodo(any())).thenAnswer((_) async => {});
      await updateTodo(tTodo);
      verify(() => mockRepository.updateTodo(tTodo)).called(1);
    });

    test('DeleteTodo should call repository', () async {
      when(() => mockRepository.deleteTodo(any())).thenAnswer((_) async => {});
      await deleteTodo(1);
      verify(() => mockRepository.deleteTodo(1)).called(1);
    });

    test('GetFocusSessionsCount should call repository', () async {
      final tDate = DateTime(2026, 1, 1);
      when(() => mockRepository.getFocusSessionsCountForDay(any())).thenAnswer((_) async => 5);
      final result = await getFocusSessionsCount(tDate);
      expect(result, 5);
      verify(() => mockRepository.getFocusSessionsCountForDay(tDate)).called(1);
    });
  });
}
