import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'focus_event.dart';
import 'focus_state.dart';
import '../../../domain/repositories/todo_repository.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  final TodoRepository repository;
  StreamSubscription<int>? _tickerSubscription;

  FocusBloc({required this.repository}) : super(FocusState.initial()) {
    on<LoadFocusSessionsEvent>((event, emit) async {
      final count = await repository.getFocusSessionsCountForDay(DateTime.now());
      emit(state.copyWith(sessionsToday: count));
    });

    on<StartTimerEvent>((event, emit) {
      if (state.remainingTime > 0) {
        emit(state.copyWith(isRunning: true));
        _tickerSubscription?.cancel();
        _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => state.remainingTime - 1)
            .take(state.remainingTime)
            .listen((remaining) => add(TickEvent(remaining)));
      }
    });

    on<StopTimerEvent>((event, emit) {
      _tickerSubscription?.cancel();
      emit(state.copyWith(isRunning: false));
    });

    on<ResetTimerEvent>((event, emit) {
      _tickerSubscription?.cancel();
      emit(state.copyWith(
        isRunning: false,
        remainingTime: state.isWorking ? state.workDuration : state.breakDuration,
      ));
    });

    on<ToggleModeEvent>((event, emit) {
      _tickerSubscription?.cancel();
      final newIsWorking = !state.isWorking;
      final duration = newIsWorking ? state.workDuration : state.breakDuration;
      emit(state.copyWith(
        isRunning: false,
        isWorking: newIsWorking,
        remainingTime: duration,
      ));
    });

    on<ChangeDurationEvent>((event, emit) {
      _tickerSubscription?.cancel();
      emit(state.copyWith(
        isRunning: false,
        workDuration: event.workDuration,
        breakDuration: event.breakDuration,
        sessionsTarget: event.sessionsTarget,
        remainingTime: state.isWorking ? event.workDuration : event.breakDuration,
      ));
    });

    on<TickEvent>((event, emit) async {
      if (event.remainingTime > 0) {
        emit(state.copyWith(remainingTime: event.remainingTime));
      } else {
        _tickerSubscription?.cancel();
        
        if (state.isWorking) {
          await repository.completeFocusSession(state.workDuration);
          add(LoadFocusSessionsEvent()); // Reload count
        }

        final newIsWorking = !state.isWorking;
        final duration = newIsWorking ? state.workDuration : state.breakDuration;
        emit(state.copyWith(
          isRunning: false,
          isWorking: newIsWorking,
          remainingTime: duration,
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
