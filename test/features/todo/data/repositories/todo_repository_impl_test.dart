import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:taskora/features/todo/data/models/todo_model.dart';
import 'package:taskora/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';

class MockTodoLocalDataSource extends Mock implements TodoLocalDataSource {}

void main() {
  late TodoRepositoryImpl repository;
  late MockTodoLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockTodoLocalDataSource();
    repository = TodoRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final tTodoModel = TodoModel(
    id: 1,
    title: 'Test',
    description: 'Desc',
    dateTime: DateTime(2026, 1, 1),
    priority: TodoPriority.medium,
    category: 'Work',
    notificationId: 1,
    isCompleted: false,
    isPinned: false,
    enableReminder: true,
  );

  final tTodoEntity = tTodoModel; // TodoModel extends TodoEntity

  group('getTodos', () {
    test('should return list of todos from local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getTodos()).thenAnswer((_) async => [tTodoModel]);

      // Act
      final result = await repository.getTodos();

      // Assert
      expect(result, [tTodoEntity]);
      verify(() => mockLocalDataSource.getTodos()).called(1);
    });
  });
}
