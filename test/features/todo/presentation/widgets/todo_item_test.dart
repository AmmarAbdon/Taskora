import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';
import 'package:taskora/features/todo/presentation/widgets/todo_item.dart';

void main() {
  final tTodo = TodoEntity(
    id: 1,
    title: 'Test Task',
    description: 'Description',
    dateTime: DateTime(2026, 1, 1),
    priority: TodoPriority.medium,
    category: 'Work',
    notificationId: 1,
  );

  Widget createWidgetUnderTest({
    required TodoEntity todo,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TodoItem(
          todo: todo,
          onToggle: onToggle,
          onDelete: onDelete,
          onTap: () {},
        ),
      ),
    );
  }

  group('TodoItem Widget Test', () {
    testWidgets('should display todo title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        todo: tTodo,
        onToggle: () {},
        onDelete: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('should call onToggle when toggle button is pressed', (WidgetTester tester) async {
      bool toggleCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        todo: tTodo,
        onToggle: () => toggleCalled = true,
        onDelete: () {},
      ));
      await tester.pumpAndSettle();

      // Find the toggle button (GestureDetector wrapping the AnimatedContainer)
      // It has check_rounded or radio_button_unchecked_rounded icon
      await tester.tap(find.byIcon(Icons.radio_button_unchecked_rounded));
      await tester.pump();

      expect(toggleCalled, true);
    });

    testWidgets('should call onDelete when delete icon is pressed', (WidgetTester tester) async {
      bool deleteCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        todo: tTodo,
        onToggle: () {},
        onDelete: () => deleteCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump();

      expect(deleteCalled, true);
    });
  });
}
