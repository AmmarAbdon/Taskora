import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/core/error/exceptions.dart';
import 'package:taskora/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:taskora/features/todo/data/models/todo_model.dart';
import 'package:taskora/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';

class MockTodoLocalDataSource extends Mock implements TodoLocalDataSource {}

void main() {
  late TodoRepositoryImpl repository;
  late MockTodoLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockTodoLocalDataSource();
    repository = TodoRepositoryImpl(localDataSource: mockDataSource);
  });

  final tTodoModel = TodoModel(
    id: 1,
    title: 'Test',
    description: 'Desc',
    dateTime: DateTime(2026),
    priority: TodoPriority.medium,
    category: 'Work',
    notificationId: 103,
  );

  group('TodoRepositoryImpl - Production Level Coverage', () {
    test('should return TodoEntity when data source call is successful', () async {
      // Arrange
      when(() => mockDataSource.getTodos()).thenAnswer((_) async => [tTodoModel]);

      // Act
      final result = await repository.getTodos();

      // Assert
      expect(result.length, 1);
      expect(result.first.title, tTodoModel.title);
      verify(() => mockDataSource.getTodos()).called(1);
    });

    test('should throw CacheException when data source fails', () async {
      // Arrange
      when(() => mockDataSource.getTodos()).thenThrow(CacheException('DB Error'));

      // Act
      final call = repository.getTodos;

      // Assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });
}
