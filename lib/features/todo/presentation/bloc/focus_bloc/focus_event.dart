import 'package:equatable/equatable.dart';

abstract class FocusEvent extends Equatable {
  const FocusEvent();
  @override
  List<Object?> get props => [];
}

class LoadFocusSessionsEvent extends FocusEvent {}

class StartTimerEvent extends FocusEvent {}
class StopTimerEvent extends FocusEvent {}
class ResetTimerEvent extends FocusEvent {}
class ToggleModeEvent extends FocusEvent {}
class ChangeDurationEvent extends FocusEvent {
  final int workDuration;
  final int breakDuration;
  final int sessionsTarget;
  const ChangeDurationEvent({
    required this.workDuration, 
    required this.breakDuration,
    required this.sessionsTarget,
  });
  @override
  List<Object?> get props => [workDuration, breakDuration, sessionsTarget];
}
class TickEvent extends FocusEvent {
  final int remainingTime;
  const TickEvent(this.remainingTime);
  @override
  List<Object?> get props => [remainingTime];
}
