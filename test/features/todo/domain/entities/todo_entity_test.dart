import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';

void main() {
  final tDate = DateTime(2026, 1, 1);
  final tTodo = TodoEntity(
    id: 1,
    title: 'Test Title',
    description: 'Test Desc',
    dateTime: tDate,
    priority: TodoPriority.high,
    category: 'Work',
    notificationId: 101,
  );

  group('TodoEntity', () {
    test('should return a valid copy with updated fields', () {
      // Arrange & Act
      final result = tTodo.copyWith(title: 'New Title', isCompleted: true);

      // Assert
      expect(result.title, 'New Title');
      expect(result.isCompleted, true);
      expect(result.id, tTodo.id);
      expect(result.description, tTodo.description);
      expect(result.dateTime, tTodo.dateTime);
    });

    test('should support value equality', () {
      // Arrange
      final tTodo2 = TodoEntity(
        id: 1,
        title: 'Test Title',
        description: 'Test Desc',
        dateTime: tDate,
        priority: TodoPriority.high,
        category: 'Work',
        notificationId: 101,
      );

      // Assert
      expect(tTodo, tTodo2);
    });
  });
}
