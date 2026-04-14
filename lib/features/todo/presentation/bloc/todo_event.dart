import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_entity.dart';

abstract class TodoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final TodoEntity todo;
  AddTodoEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class UpdateTodoEvent extends TodoEvent {
  final TodoEntity todo;
  UpdateTodoEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class DeleteTodoEvent extends TodoEvent {
  final int id;
  final int notificationId;
  DeleteTodoEvent(this.id, this.notificationId);

  @override
  List<Object?> get props => [id, notificationId];
}

class ToggleTodoStatusEvent extends TodoEvent {
  final TodoEntity todo;
  ToggleTodoStatusEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class SearchTodosEvent extends TodoEvent {
  final String query;
  SearchTodosEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterTodosEvent extends TodoEvent {
  final String filter; // 'All', 'Completed', 'Pending'
  FilterTodosEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}
