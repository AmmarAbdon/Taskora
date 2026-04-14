import 'package:equatable/equatable.dart';

enum TodoPriority { low, medium, high }

class TodoEntity extends Equatable {
  final int? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;
  final bool isPinned;
  final TodoPriority priority;
  final String category;
  final int notificationId;
  final bool enableReminder;

  const TodoEntity({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.isPinned = false,
    this.priority = TodoPriority.low,
    this.category = 'Personal',
    required this.notificationId,
    this.enableReminder = false,
  });

  TodoEntity copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    bool? isPinned,
    TodoPriority? priority,
    String? category,
    int? notificationId,
    bool? enableReminder,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isPinned: isPinned ?? this.isPinned,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      notificationId: notificationId ?? this.notificationId,
      enableReminder: enableReminder ?? this.enableReminder,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dateTime,
    isCompleted,
    isPinned,
    priority,
    category,
    notificationId,
    enableReminder,
  ];
}
