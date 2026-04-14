import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    super.id,
    required super.title,
    required super.description,
    required super.dateTime,
    super.isCompleted,
    super.isPinned,
    super.priority,
    super.category,
    required super.notificationId,
    super.enableReminder,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      isCompleted: json['isCompleted'] == 1,
      isPinned: json['isPinned'] == 1,
      priority: TodoPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TodoPriority.low,
      ),
      category: json['category'] ?? 'Personal',
      notificationId: json['notificationId'],
      enableReminder: false, // Not stored in DB; always false when loading
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'isPinned': isPinned ? 1 : 0,
      'priority': priority.toString(),
      'category': category,
      'notificationId': notificationId,
    };
  }

  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dateTime: entity.dateTime,
      isCompleted: entity.isCompleted,
      isPinned: entity.isPinned,
      priority: entity.priority,
      category: entity.category,
      notificationId: entity.notificationId,
      enableReminder: entity.enableReminder,
    );
  }
}
