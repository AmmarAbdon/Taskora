import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/core/services/notification_service.dart';
import 'package:taskora/core/usecases/usecase.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';
import 'package:taskora/features/todo/domain/usecases/add_todo.dart';
import 'package:taskora/features/todo/domain/usecases/delete_todo.dart';
import 'package:taskora/features/todo/domain/usecases/get_focus_sessions_count.dart';
import 'package:taskora/features/todo/domain/usecases/get_todos.dart';
import 'package:taskora/features/todo/domain/usecases/update_todo.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_event.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_state.dart';
import 'package:taskora/core/error/exceptions.dart';

class MockGetTodos extends Mock implements GetTodos {}
class MockAddTodo extends Mock implements AddTodo {}
class MockUpdateTodo extends Mock implements UpdateTodo {}
class MockDeleteTodo extends Mock implements DeleteTodo {}
class MockGetFocusSessionsCount extends Mock implements GetFocusSessionsCount {}
class MockNotificationService extends Mock implements NotificationService {}

class FakeTodoEntity extends Fake implements TodoEntity {}
class FakeNoParams extends Fake implements NoParams {}

void main() {
  late TodoBloc bloc;
  late MockGetTodos mockGetTodos;
  late MockAddTodo mockAddTodo;
  late MockUpdateTodo mockUpdateTodo;
  late MockDeleteTodo mockDeleteTodo;
  late MockGetFocusSessionsCount mockGetFocusSessionsCount;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
    registerFallbackValue(FakeTodoEntity());
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockGetTodos = MockGetTodos();
    mockAddTodo = MockAddTodo();
    mockUpdateTodo = MockUpdateTodo();
    mockDeleteTodo = MockDeleteTodo();
    mockGetFocusSessionsCount = MockGetFocusSessionsCount();
    mockNotificationService = MockNotificationService();

    bloc = TodoBloc(
      getTodos: mockGetTodos,
      addTodo: mockAddTodo,
      updateTodo: mockUpdateTodo,
      deleteTodo: mockDeleteTodo,
      getFocusSessionsCount: mockGetFocusSessionsCount,
      notificationService: mockNotificationService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tTodo = TodoEntity(
    id: 1,
    title: 'Test',
    description: 'Desc',
    dateTime: DateTime(2026, 1, 1),
    priority: TodoPriority.medium,
    category: 'Work',
    notificationId: 1,
  );

  final tTodosList = [tTodo];

  group('TodoBloc', () {
    test('initial state should be TodoInitial', () {
      expect(bloc.state, TodoInitial());
    });

    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoading, TodoLoaded] when LoadTodosEvent is successful',
      build: () {
        when(() => mockGetTodos(any())).thenAnswer((_) async => tTodosList);
        when(() => mockGetFocusSessionsCount(any())).thenAnswer((_) async => 5);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadTodosEvent()),
      expect: () => [
        TodoLoading(),
        TodoLoaded(todos: tTodosList, focusSessionsToday: 5),
      ],
      verify: (bloc) {
        verify(() => mockGetTodos(any())).called(1);
        verify(() => mockGetFocusSessionsCount(any())).called(1);
      },
    );

    blocTest<TodoBloc, TodoState>(
      'emits [TodoActionSuccess] and reloads todos when AddTodoEvent is successful',
      build: () {
        when(() => mockAddTodo(any())).thenAnswer((_) async => {});
        // Mocking the subsequent LoadTodosEvent
        when(() => mockGetTodos(any())).thenAnswer((_) async => tTodosList);
        when(() => mockGetFocusSessionsCount(any())).thenAnswer((_) async => 5);
        return bloc;
      },
      act: (bloc) => bloc.add(AddTodoEvent(tTodo)),
      expect: () => [
        TodoActionSuccess("Task added successfully! 🎉"),
        TodoLoading(), // from the 'add(LoadTodosEvent())' call inside _onAddTodo
        TodoLoaded(todos: tTodosList, focusSessionsToday: 5),
      ],
      verify: (bloc) {
        verify(() => mockAddTodo(tTodo)).called(1);
      },
    );

    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoading, TodoError] with fallback message when LoadTodosEvent fails with generic exception',
      build: () {
        when(() => mockGetTodos(any())).thenThrow(Exception('Database Error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadTodosEvent()),
      expect: () => [
        TodoLoading(),
        TodoError('An unexpected error occurred while loading tasks'),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoading, TodoError] with specific message when LoadTodosEvent fails with CacheException',
      build: () {
        when(() => mockGetTodos(any())).thenThrow(CacheException('Cache Failure'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadTodosEvent()),
      expect: () => [
        TodoLoading(),
        TodoError('Cache Failure'),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits [TodoError] with fallback message when AddTodoEvent fails',
      build: () {
        when(() => mockAddTodo(any())).thenThrow(Exception('Save Error'));
        return bloc;
      },
      act: (bloc) => bloc.add(AddTodoEvent(tTodo)),
      expect: () => [
        TodoError('An unexpected error occurred while adding the task'),
      ],
    );
  });
}
