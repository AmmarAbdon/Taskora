import 'package:flutter_bloc/flutter_bloc.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// Manages the state of the calendar view, specifically the selected and focused days.
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarState.initial()) {
    on<SelectDayEvent>((event, emit) {
      emit(state.copyWith(
        selectedDay: event.selectedDay,
        focusedDay: event.focusedDay,
      ));
    });
  }
}
