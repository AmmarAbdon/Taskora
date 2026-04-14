import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/update_todo.dart';
import '../../domain/entities/todo_entity.dart';
import 'todo_event.dart';
import 'todo_state.dart';
import '../../../../core/error/exceptions.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;
  final NotificationService notificationService;

  List<TodoEntity> _allTodos = [];

  TodoBloc({
    required this.getTodos,
    required this.addTodo,
    required this.updateTodo,
    required this.deleteTodo,
    required this.notificationService,
  }) : super(TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<ToggleTodoStatusEvent>(_onToggleTodoStatus);
    on<SearchTodosEvent>(_onSearchTodos);
    on<FilterTodosEvent>(_onFilterTodos);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());
    try {
      _allTodos = await getTodos(NoParams());
      emit(TodoLoaded(todos: _allTodos));
    } on CacheException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError("An unexpected error occurred while loading tasks"));
    }
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    try {
      await addTodo(event.todo);

      // Only schedule if user enabled reminder AND time is in the future
      if (event.todo.enableReminder &&
          event.todo.dateTime.isAfter(DateTime.now())) {
        try {
          await notificationService.scheduleNotification(event.todo);
        } catch (e) {
          // Task was saved successfully; notification failed — surface a warning
          emit(
            TodoError("Task saved, but notification failed: ${e.toString()}"),
          );
        }
      }

      add(LoadTodosEvent());
    } on CacheException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError("An unexpected error occurred while adding the task"));
    }
  }

  Future<void> _onUpdateTodo(
    UpdateTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await updateTodo(event.todo);
      await notificationService.cancelNotification(event.todo.notificationId);

      if (event.todo.enableReminder &&
          !event.todo.isCompleted &&
          event.todo.dateTime.isAfter(DateTime.now())) {
        try {
          await notificationService.scheduleNotification(event.todo);
        } catch (e) {
          emit(
            TodoError("Task updated, but notification failed: ${e.toString()}"),
          );
        }
      }

      add(LoadTodosEvent());
    } on CacheException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError("An unexpected error occurred while updating the task"));
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await deleteTodo(event.id);
      await notificationService.cancelNotification(event.notificationId);
      add(LoadTodosEvent());
    } on CacheException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError("An unexpected error occurred while deleting the task"));
    }
  }

  Future<void> _onToggleTodoStatus(
    ToggleTodoStatusEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final updatedTodo = event.todo.copyWith(
        isCompleted: !event.todo.isCompleted,
      );
      await updateTodo(updatedTodo);

      if (updatedTodo.isCompleted) {
        await notificationService.cancelNotification(
          updatedTodo.notificationId,
        );
      } else if (updatedTodo.dateTime.isAfter(DateTime.now())) {
        await notificationService.scheduleNotification(updatedTodo);
      }

      add(LoadTodosEvent());
    } on CacheException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(
        TodoError("An unexpected error occurred while toggling task status"),
      );
    }
  }

  void _onSearchTodos(SearchTodosEvent event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
      _applyFilterAndSearch(emit, currentState.filter, event.query);
    }
  }

  void _onFilterTodos(FilterTodosEvent event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      emit(currentState.copyWith(filter: event.filter));
      _applyFilterAndSearch(emit, event.filter, currentState.searchQuery);
    }
  }

  void _applyFilterAndSearch(
    Emitter<TodoState> emit,
    String filter,
    String query,
  ) {
    List<TodoEntity> filtered = _allTodos;

    if (filter == 'Completed') {
      filtered = filtered.where((t) => t.isCompleted).toList();
    } else if (filter == 'Pending') {
      filtered = filtered.where((t) => !t.isCompleted).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.title.toLowerCase().contains(query.toLowerCase()) ||
                t.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    emit((state as TodoLoaded).copyWith(todos: filtered));
  }
}
