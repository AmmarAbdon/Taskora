import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';
import 'package:taskora/features/todo/domain/repositories/todo_repository.dart';
import 'package:taskora/features/todo/domain/usecases/add_todo.dart';

class MockTodoRepository extends Mock implements TodoRepository {}
class FakeTodoEntity extends Fake implements TodoEntity {}

void main() {
  late AddTodo usecase;
  late MockTodoRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeTodoEntity());
  });

  setUp(() {
    mockRepository = MockTodoRepository();
    usecase = AddTodo(mockRepository);
  });

  final tTodo = TodoEntity(
    id: 1,
    title: 'Test Task',
    description: 'Test Desc',
    dateTime: DateTime(2026),
    priority: TodoPriority.high,
    category: 'Work',
    notificationId: 101,
  );

  group('AddTodo UseCase - Production Standard', () {
    test('should call saveTodo on the repository and complete successfully', () async {
      // Arrange
      when(() => mockRepository.addTodo(any())).thenAnswer((_) async => {});

      // Act
      await usecase(tTodo);

      // Assert
      verify(() => mockRepository.addTodo(tTodo)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(() => mockRepository.addTodo(any())).thenThrow(Exception('DB Error'));

      // Act
      final call = usecase(tTodo);

      // Assert
      expect(() => call, throwsException);
    });
  });
}
