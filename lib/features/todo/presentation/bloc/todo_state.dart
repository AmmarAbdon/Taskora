import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_entity.dart';

abstract class TodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoEntity> todos;
  final String filter;
  final String searchQuery;

  TodoLoaded({required this.todos, this.filter = 'All', this.searchQuery = ''});

  @override
  List<Object?> get props => [todos, filter, searchQuery];

  TodoLoaded copyWith({
    List<TodoEntity>? todos,
    String? filter,
    String? searchQuery,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TodoError extends TodoState {
  final String message;
  TodoError(this.message);

  @override
  List<Object?> get props => [message];
}

class TodoActionSuccess extends TodoState {
  final String message;
  TodoActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
