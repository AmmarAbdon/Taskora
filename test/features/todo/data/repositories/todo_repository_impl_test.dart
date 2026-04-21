import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:taskora/features/todo/data/models/focus_session_model.dart';
import 'package:taskora/features/todo/data/models/todo_model.dart';
import 'package:taskora/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';

class MockTodoLocalDataSource extends Mock implements TodoLocalDataSource {}

void main() {
  late TodoRepositoryImpl repository;
  late MockTodoLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(TodoModel(
      id: 0,
      title: '',
      description: '',
      dateTime: DateTime(2026),
      priority: TodoPriority.low,
      category: 'Personal',
      notificationId: 0,
    ));
    registerFallbackValue(FocusSessionModel(date: '2026-01-01', duration: 0));
  });

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
  group('addTodo', () {
    test('should call localDataSource.addTodo with converted TodoModel', () async {
      when(() => mockLocalDataSource.addTodo(any())).thenAnswer((_) async => {});

      await repository.addTodo(tTodoEntity);

      verify(() => mockLocalDataSource.addTodo(any())).called(1);
    });
  });

  group('updateTodo', () {
    test('should call localDataSource.updateTodo with converted TodoModel', () async {
      when(() => mockLocalDataSource.updateTodo(any())).thenAnswer((_) async => {});

      await repository.updateTodo(tTodoEntity);

      verify(() => mockLocalDataSource.updateTodo(any())).called(1);
    });
  });

  group('deleteTodo', () {
    test('should call localDataSource.deleteTodo with the given id', () async {
      when(() => mockLocalDataSource.deleteTodo(any())).thenAnswer((_) async => {});

      await repository.deleteTodo(1);

      verify(() => mockLocalDataSource.deleteTodo(1)).called(1);
    });
  });

  group('completeFocusSession', () {
    test('should call localDataSource.addFocusSession with formatted date and duration', () async {
      when(() => mockLocalDataSource.addFocusSession(any())).thenAnswer((_) async => {});

      await repository.completeFocusSession(1500);

      verify(() => mockLocalDataSource.addFocusSession(any())).called(1);
    });
  });

  group('getFocusSessionsCountForDay', () {
    test('should return count from localDataSource for the given date', () async {
      when(() => mockLocalDataSource.getFocusSessionsCountForDay(any()))
          .thenAnswer((_) async => 7);

      final result = await repository.getFocusSessionsCountForDay(DateTime(2026, 5, 20));

      expect(result, 7);
      verify(() => mockLocalDataSource.getFocusSessionsCountForDay(any())).called(1);
    });
  });
}
