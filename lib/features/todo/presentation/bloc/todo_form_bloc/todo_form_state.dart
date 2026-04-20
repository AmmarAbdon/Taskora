import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/todo_entity.dart';

class TodoFormState extends Equatable {
  final TodoEntity? todo;
  final String title;
  final String description;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final TodoPriority selectedPriority;
  final String selectedCategory;
  final bool isPinned;
  final bool enableReminder;

  const TodoFormState({
    this.todo,
    required this.title,
    required this.description,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPriority,
    required this.selectedCategory,
    required this.isPinned,
    required this.enableReminder,
  });

  factory TodoFormState.initial() => TodoFormState(
        title: '',
        description: '',
        selectedDate: DateTime.now(),
        selectedTime: TimeOfDay.now(),
        selectedPriority: TodoPriority.low,
        selectedCategory: 'Personal',
        isPinned: false,
        enableReminder: true,
      );

  TodoFormState copyWith({
    TodoEntity? todo,
    String? title,
    String? description,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    TodoPriority? selectedPriority,
    String? selectedCategory,
    bool? isPinned,
    bool? enableReminder,
  }) {
    return TodoFormState(
      todo: todo ?? this.todo,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isPinned: isPinned ?? this.isPinned,
      enableReminder: enableReminder ?? this.enableReminder,
    );
  }

  @override
  List<Object?> get props => [
        todo,
        title,
        description,
        selectedDate,
        selectedTime,
        selectedPriority,
        selectedCategory,
        isPinned,
        enableReminder,
      ];
}
