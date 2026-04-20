import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();
  @override
  List<Object?> get props => [];
}

class SelectDayEvent extends CalendarEvent {
  final DateTime selectedDay;
  final DateTime focusedDay;
  const SelectDayEvent(this.selectedDay, this.focusedDay);
  @override
  List<Object?> get props => [selectedDay, focusedDay];
}
