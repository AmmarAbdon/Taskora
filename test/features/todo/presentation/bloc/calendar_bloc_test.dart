import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/todo/presentation/bloc/calendar_bloc/calendar_bloc.dart';
import 'package:taskora/features/todo/presentation/bloc/calendar_bloc/calendar_event.dart';
import 'package:taskora/features/todo/presentation/bloc/calendar_bloc/calendar_state.dart';

void main() {
  late CalendarBloc bloc;

  setUp(() {
    bloc = CalendarBloc();
  });

  tearDown(() {
    bloc.close();
  });

  group('CalendarBloc', () {
    test('initial state should have today as selectedDay and focusedDay', () {
      final state = bloc.state;
      final now = DateTime.now();
      expect(state.selectedDay.year, now.year);
      expect(state.selectedDay.month, now.month);
      expect(state.selectedDay.day, now.day);
    });

    blocTest<CalendarBloc, CalendarState>(
      'emits updated state with new selected and focused day when SelectDayEvent is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(SelectDayEvent(
        DateTime(2026, 12, 25),
        DateTime(2026, 12, 25),
      )),
      expect: () => [
        isA<CalendarState>()
            .having((s) => s.selectedDay, 'selectedDay', DateTime(2026, 12, 25))
            .having((s) => s.focusedDay, 'focusedDay', DateTime(2026, 12, 25)),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'emits a second updated state when SelectDayEvent is dispatched twice',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(SelectDayEvent(
          DateTime(2026, 5, 1),
          DateTime(2026, 5, 1),
        ));
        bloc.add(SelectDayEvent(
          DateTime(2026, 7, 4),
          DateTime(2026, 7, 4),
        ));
      },
      expect: () => [
        isA<CalendarState>().having((s) => s.selectedDay.month, 'month', 5),
        isA<CalendarState>().having((s) => s.selectedDay.month, 'month', 7),
      ],
    );
  });
}
