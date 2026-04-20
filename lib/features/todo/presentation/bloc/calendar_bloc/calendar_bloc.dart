import 'package:flutter_bloc/flutter_bloc.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

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
