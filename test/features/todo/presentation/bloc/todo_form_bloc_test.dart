import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/todo/domain/entities/todo_entity.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_form_bloc/todo_form_bloc.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_form_bloc/todo_form_event.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_form_bloc/todo_form_state.dart';

void main() {
  late TodoFormBloc bloc;

  final tExistingTodo = TodoEntity(
    id: 1,
    title: 'Existing Title',
    description: 'Existing Desc',
    dateTime: DateTime(2026, 6, 15, 10, 30),
    priority: TodoPriority.high,
    category: 'Work',
    notificationId: 42,
    isPinned: true,
    enableReminder: true,
  );

  setUp(() {
    bloc = TodoFormBloc();
  });

  tearDown(() {
    bloc.close();
  });

  group('TodoFormBloc', () {
    test('initial state should be TodoFormState.initial()', () {
      final state = bloc.state;
      expect(state.title, '');
      expect(state.description, '');
      expect(state.selectedPriority, TodoPriority.low);
      expect(state.selectedCategory, 'Personal');
      expect(state.isPinned, false);
      expect(state.enableReminder, true);
      expect(state.todo, isNull);
    });

    // --- InitializeFormEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'populates state from existing todo when InitializeFormEvent is dispatched with a todo',
      build: () => bloc,
      act: (bloc) => bloc.add(InitializeFormEvent(tExistingTodo)),
      expect: () => [
        isA<TodoFormState>()
            .having((s) => s.todo, 'todo', tExistingTodo)
            .having((s) => s.title, 'title', 'Existing Title')
            .having((s) => s.description, 'description', 'Existing Desc')
            .having((s) => s.selectedPriority, 'priority', TodoPriority.high)
            .having((s) => s.selectedCategory, 'category', 'Work')
            .having((s) => s.isPinned, 'isPinned', true)
            .having((s) => s.enableReminder, 'enableReminder', true),
      ],
    );

    blocTest<TodoFormBloc, TodoFormState>(
      'resets state to initial when InitializeFormEvent is dispatched with null',
      build: () {
        // First load an existing todo, so we know we are resetting
        final b = TodoFormBloc();
        b.add(InitializeFormEvent(tExistingTodo));
        return b;
      },
      act: (bloc) => bloc.add(InitializeFormEvent(null)),
      skip: 1,
      expect: () => [
        isA<TodoFormState>()
            .having((s) => s.todo, 'todo', isNull)
            .having((s) => s.title, 'title', ''),
      ],
    );

    // --- TitleChangedEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'updates title when TitleChangedEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(TitleChangedEvent('New Title')),
      expect: () => [
        isA<TodoFormState>().having((s) => s.title, 'title', 'New Title'),
      ],
    );

    // --- DescriptionChangedEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'updates description when DescriptionChangedEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(DescriptionChangedEvent('New Desc')),
      expect: () => [
        isA<TodoFormState>().having((s) => s.description, 'description', 'New Desc'),
      ],
    );

    // --- DateChangedEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'updates selectedDate when DateChangedEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(DateChangedEvent(DateTime(2027, 3, 20))),
      expect: () => [
        isA<TodoFormState>().having(
          (s) => s.selectedDate,
          'selectedDate',
          DateTime(2027, 3, 20),
        ),
      ],
    );

    // --- TimeChangedEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'updates selectedTime when TimeChangedEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(TimeChangedEvent(const TimeOfDay(hour: 14, minute: 30))),
      expect: () => [
        isA<TodoFormState>().having(
          (s) => s.selectedTime,
          'selectedTime',
          const TimeOfDay(hour: 14, minute: 30),
        ),
      ],
    );

    // --- PriorityChangedEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'updates selectedPriority when PriorityChangedEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(PriorityChangedEvent(TodoPriority.high)),
      expect: () => [
        isA<TodoFormState>().having(
          (s) => s.selectedPriority,
          'priority',
          TodoPriority.high,
        ),
      ],
    );

    // --- CategoryChangedEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'updates selectedCategory when CategoryChangedEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(CategoryChangedEvent('Work')),
      expect: () => [
        isA<TodoFormState>().having((s) => s.selectedCategory, 'category', 'Work'),
      ],
    );

    // --- PinnedChangedEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'toggles isPinned when PinnedChangedEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(PinnedChangedEvent(true)),
      expect: () => [
        isA<TodoFormState>().having((s) => s.isPinned, 'isPinned', true),
      ],
    );

    // --- ReminderChangedEvent ---
    blocTest<TodoFormBloc, TodoFormState>(
      'toggles enableReminder when ReminderChangedEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(ReminderChangedEvent(false)),
      expect: () => [
        isA<TodoFormState>().having((s) => s.enableReminder, 'enableReminder', false),
      ],
    );

    // --- Sequence of events ---
    blocTest<TodoFormBloc, TodoFormState>(
      'correctly applies multiple sequential events',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(TitleChangedEvent('My Task'));
        bloc.add(DescriptionChangedEvent('Details'));
        bloc.add(PriorityChangedEvent(TodoPriority.medium));
        bloc.add(CategoryChangedEvent('Health'));
      },
      expect: () => [
        isA<TodoFormState>().having((s) => s.title, 'title', 'My Task'),
        isA<TodoFormState>().having((s) => s.description, 'description', 'Details'),
        isA<TodoFormState>().having((s) => s.selectedPriority, 'priority', TodoPriority.medium),
        isA<TodoFormState>().having((s) => s.selectedCategory, 'category', 'Health'),
      ],
    );
  });
}
