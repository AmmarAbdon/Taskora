import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';
import 'package:taskora/features/todo/domain/repositories/todo_repository.dart';
import 'package:taskora/features/todo/domain/usecases/add_todo.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class FakeTodoEntity extends Fake implements TodoEntity {}

void main() {
  late AddTodo usecase;
  late MockTodoRepository mockTodoRepository;

  setUpAll(() {
    registerFallbackValue(FakeTodoEntity());
  });

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    usecase = AddTodo(mockTodoRepository);
  });

  final tTodo = TodoEntity(
    id: 1,
    title: 'Test',
    description: 'Desc',
    dateTime: DateTime.now(),
    priority: TodoPriority.medium,
    category: 'Work',
    notificationId: 1,
  );

  test('should call repository to add a todo', () async {
    // Arrange
    when(() => mockTodoRepository.addTodo(any())).thenAnswer((_) async => {});

    // Act
    await usecase(tTodo);

    // Assert
    verify(() => mockTodoRepository.addTodo(tTodo)).called(1);
    verifyNoMoreInteractions(mockTodoRepository);
  });
}
