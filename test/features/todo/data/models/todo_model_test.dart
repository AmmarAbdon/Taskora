import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/todo/data/models/todo_model.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';

void main() {
  final tDateTime = DateTime(2026, 1, 1, 12, 0);
  final tTodoModel = TodoModel(
    id: 1,
    title: 'Test',
    description: 'Desc',
    dateTime: tDateTime,
    priority: TodoPriority.high,
    category: 'Work',
    notificationId: 101,
    isCompleted: false,
    isPinned: true,
    enableReminder: true,
  );

  final tTodoJson = {
    'id': 1,
    'title': 'Test',
    'description': 'Desc',
    'dateTime': tDateTime.toIso8601String(),
    'isCompleted': 0,
    'isPinned': 1,
    'priority': 'TodoPriority.high',
    'category': 'Work',
    'notificationId': 101,
  };

  group('TodoModel Coverage', () {
    test('should be a subclass of TodoEntity', () {
      expect(tTodoModel, isA<TodoEntity>());
    });

    test('fromJson should return a valid model', () {
      final result = TodoModel.fromJson(tTodoJson);
      expect(result.id, tTodoModel.id);
      expect(result.title, tTodoModel.title);
      expect(result.priority, tTodoModel.priority);
    });

    test('toJson should return a JSON map containing proper data', () {
      final result = tTodoModel.toJson();
      expect(result, tTodoJson);
    });

    test('fromEntity should create a TodoModel from a TodoEntity', () {
      final entity = TodoEntity(
        id: 1,
        title: 'Test',
        description: 'Desc',
        dateTime: tDateTime,
        priority: TodoPriority.high,
        category: 'Work',
        notificationId: 101,
      );
      final result = TodoModel.fromEntity(entity);
      expect(result.title, entity.title);
      expect(result.notificationId, entity.notificationId);
    });
  });
}
