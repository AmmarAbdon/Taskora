import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/todo_entity.dart';

abstract class TodoFormEvent extends Equatable {
  const TodoFormEvent();
  @override
  List<Object?> get props => [];
}

class InitializeFormEvent extends TodoFormEvent {
  final TodoEntity? todo;
  const InitializeFormEvent(this.todo);
  @override
  List<Object?> get props => [todo];
}

class TitleChangedEvent extends TodoFormEvent {
  final String title;
  const TitleChangedEvent(this.title);
  @override
  List<Object?> get props => [title];
}

class DescriptionChangedEvent extends TodoFormEvent {
  final String description;
  const DescriptionChangedEvent(this.description);
  @override
  List<Object?> get props => [description];
}

class DateChangedEvent extends TodoFormEvent {
  final DateTime date;
  const DateChangedEvent(this.date);
  @override
  List<Object?> get props => [date];
}

class TimeChangedEvent extends TodoFormEvent {
  final TimeOfDay time;
  const TimeChangedEvent(this.time);
  @override
  List<Object?> get props => [time];
}

class PriorityChangedEvent extends TodoFormEvent {
  final TodoPriority priority;
  const PriorityChangedEvent(this.priority);
  @override
  List<Object?> get props => [priority];
}

class CategoryChangedEvent extends TodoFormEvent {
  final String category;
  const CategoryChangedEvent(this.category);
  @override
  List<Object?> get props => [category];
}

class PinnedChangedEvent extends TodoFormEvent {
  final bool isPinned;
  const PinnedChangedEvent(this.isPinned);
  @override
  List<Object?> get props => [isPinned];
}

class ReminderChangedEvent extends TodoFormEvent {
  final bool enableReminder;
  const ReminderChangedEvent(this.enableReminder);
  @override
  List<Object?> get props => [enableReminder];
}
