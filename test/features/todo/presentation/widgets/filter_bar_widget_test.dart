import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/todo/presentation/widgets/filter_bar.dart';

void main() {
  Widget buildWidget({
    required String activeFilter,
    required Function(String) onFilterChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: FilterBar(
          activeFilter: activeFilter,
          onFilterChanged: onFilterChanged,
        ),
      ),
    );
  }

  group('FilterBar Widget', () {
    testWidgets('renders All, Pending, and Completed chips', (tester) async {
      await tester.pumpWidget(buildWidget(
        activeFilter: 'All',
        onFilterChanged: (_) {},
      ));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('marks "All" chip as selected when activeFilter is All', (tester) async {
      await tester.pumpWidget(buildWidget(
        activeFilter: 'All',
        onFilterChanged: (_) {},
      ));

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      final allChip = chips.firstWhere(
        (c) => (c.label as Text).data == 'All',
      );
      expect(allChip.selected, isTrue);
    });

    testWidgets('marks "Pending" chip as selected when activeFilter is Pending', (tester) async {
      await tester.pumpWidget(buildWidget(
        activeFilter: 'Pending',
        onFilterChanged: (_) {},
      ));

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      final pendingChip = chips.firstWhere((c) => (c.label as Text).data == 'Pending');
      final allChip = chips.firstWhere((c) => (c.label as Text).data == 'All');

      expect(pendingChip.selected, isTrue);
      expect(allChip.selected, isFalse);
    });

    testWidgets('marks "Completed" chip as selected when activeFilter is Completed', (tester) async {
      await tester.pumpWidget(buildWidget(
        activeFilter: 'Completed',
        onFilterChanged: (_) {},
      ));

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      final completedChip = chips.firstWhere((c) => (c.label as Text).data == 'Completed');
      expect(completedChip.selected, isTrue);
    });

    testWidgets('calls onFilterChanged with "Pending" when Pending chip is tapped', (tester) async {
      String? selected;
      await tester.pumpWidget(buildWidget(
        activeFilter: 'All',
        onFilterChanged: (f) => selected = f,
      ));

      await tester.tap(find.text('Pending'));
      await tester.pump();

      expect(selected, 'Pending');
    });

    testWidgets('calls onFilterChanged with "Completed" when Completed chip is tapped', (tester) async {
      String? selected;
      await tester.pumpWidget(buildWidget(
        activeFilter: 'All',
        onFilterChanged: (f) => selected = f,
      ));

      await tester.tap(find.text('Completed'));
      await tester.pump();

      expect(selected, 'Completed');
    });

    testWidgets('calls onFilterChanged with "All" when All chip is tapped', (tester) async {
      String? selected;
      await tester.pumpWidget(buildWidget(
        activeFilter: 'Pending',
        onFilterChanged: (f) => selected = f,
      ));

      await tester.tap(find.text('All'));
      await tester.pump();

      expect(selected, 'All');
    });
  });
}
