import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskora/main.dart' as app;
import 'package:taskora/core/services/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('Full flow: Add a new task through navigation and verify it appears', (tester) async {
      // 1. Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Wait for service locator if needed (depends on how main.dart is structured)
      await sl.allReady();
      await tester.pumpAndSettle();

      // 2. Navigate to "Add" tab (Index 1)
      final addTab = find.byIcon(Icons.add_circle_rounded);
      expect(addTab, findsOneWidget);
      await tester.tap(addTab);
      await tester.pumpAndSettle();

      // 3. Enter task details
      // Using .at(index) is safer than complex predicates
      await tester.enterText(find.byType(TextFormField).at(0), 'Integration Test Task');
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(1), 'Created by integration test');
      await tester.pumpAndSettle();

      // 4. Submit
      final createButton = find.text('CREATE TASK');
      await tester.tap(createButton);
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Wait for snackbar and navigation

      // 5. Navigate back to Home if not automatic (it should be automatic in AddTodoPage logic)
      // Actually, AddEditTodoPage calls context.read<TodoBloc>().add(AddTodoEvent(todo)) 
      // but doesn't necessarily pop if isIntegrated is true. 
      // Wait, AddEditTodoPage:85 says `if (widget.isIntegrated) { ... } else { Navigator.pop(...) }`
      // So if integrated, we stay on that tab? 
      // Actually, standard behavior might be to switch tab back. 
      // Let's assume we need to tap Home.
      
      final homeTab = find.byIcon(Icons.home_rounded);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      // 6. Verify result
      expect(find.text('Integration Test Task'), findsOneWidget);
    });
  });
}
