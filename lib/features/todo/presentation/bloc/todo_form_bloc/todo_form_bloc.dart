import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'todo_form_event.dart';
import 'todo_form_state.dart';

class TodoFormBloc extends Bloc<TodoFormEvent, TodoFormState> {
  TodoFormBloc() : super(TodoFormState.initial()) {
    on<InitializeFormEvent>((event, emit) {
      if (event.todo != null) {
        final todo = event.todo!;
        emit(TodoFormState(
          todo: todo,
          title: todo.title,
          description: todo.description,
          selectedDate: todo.dateTime,
          selectedTime: TimeOfDay.fromDateTime(todo.dateTime),
          selectedPriority: todo.priority,
          selectedCategory: todo.category,
          isPinned: todo.isPinned,
          enableReminder: todo.enableReminder,
        ));
      } else {
        emit(TodoFormState.initial());
      }
    });

    on<TitleChangedEvent>((event, emit) => emit(state.copyWith(title: event.title)));
    on<DescriptionChangedEvent>((event, emit) => emit(state.copyWith(description: event.description)));
    on<DateChangedEvent>((event, emit) => emit(state.copyWith(selectedDate: event.date)));
    on<TimeChangedEvent>((event, emit) => emit(state.copyWith(selectedTime: event.time)));
    on<PriorityChangedEvent>((event, emit) => emit(state.copyWith(selectedPriority: event.priority)));
    on<CategoryChangedEvent>((event, emit) => emit(state.copyWith(selectedCategory: event.category)));
    on<PinnedChangedEvent>((event, emit) => emit(state.copyWith(isPinned: event.isPinned)));
    on<ReminderChangedEvent>((event, emit) => emit(state.copyWith(enableReminder: event.enableReminder)));
  }
}
