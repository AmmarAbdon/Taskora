import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';
import 'package:taskora/features/todo/presentation/widgets/todo_item.dart';

void main() {
  final tTodo = TodoEntity(
    id: 1,
    title: 'Test Task',
    description: 'Desc',
    dateTime: DateTime(2026),
    priority: TodoPriority.medium,
    category: 'Work',
    notificationId: 102,
    isCompleted: false,
  );

  group('TodoItem Behavioral Widget Test', () {
    testWidgets('should trigger onToggle when the checkbox/toggle is tapped', (WidgetTester tester) async {
      // Arrange
      // Set a larger surface size to avoid hit-test issues on wide layouts
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool wasToggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: TodoItem(
                  todo: tTodo,
                  onToggle: () => wasToggled = true,
                  onTap: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Act
      final toggleFinder = find.byIcon(Icons.radio_button_unchecked_rounded);
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(wasToggled, isTrue);
    });
  });
}
