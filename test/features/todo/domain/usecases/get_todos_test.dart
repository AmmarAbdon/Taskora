import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/core/usecases/usecase.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';
import 'package:taskora/features/todo/domain/repositories/todo_repository.dart';
import 'package:taskora/features/todo/domain/usecases/get_todos.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late GetTodos useCase;
  late MockTodoRepository mockRepository;

  final tTodos = [
    TodoEntity(
      id: 1,
      title: 'Task 1',
      description: 'Desc 1',
      dateTime: DateTime(2026, 5, 1),
      priority: TodoPriority.low,
      category: 'Personal',
      notificationId: 11,
    ),
    TodoEntity(
      id: 2,
      title: 'Task 2',
      description: 'Desc 2',
      dateTime: DateTime(2026, 5, 2),
      priority: TodoPriority.high,
      category: 'Work',
      notificationId: 22,
    ),
  ];

  setUp(() {
    mockRepository = MockTodoRepository();
    useCase = GetTodos(mockRepository);
  });

  group('GetTodos UseCase', () {
    test('should return list of todos from repository on success', () async {
      when(() => mockRepository.getTodos()).thenAnswer((_) async => tTodos);

      final result = await useCase(NoParams());

      expect(result, tTodos);
      verify(() => mockRepository.getTodos()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return an empty list when repository has no todos', () async {
      when(() => mockRepository.getTodos()).thenAnswer((_) async => []);

      final result = await useCase(NoParams());

      expect(result, isEmpty);
      verify(() => mockRepository.getTodos()).called(1);
    });

    test('should propagate exceptions thrown by the repository', () async {
      when(() => mockRepository.getTodos()).thenThrow(Exception('DB Error'));

      expect(() => useCase(NoParams()), throwsA(isA<Exception>()));
    });
  });
}
