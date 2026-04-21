import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/features/todo/domain/repositories/todo_repository.dart';
import 'package:taskora/features/todo/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'package:taskora/features/todo/presentation/bloc/focus_bloc/focus_event.dart';
import 'package:taskora/features/todo/presentation/bloc/focus_bloc/focus_state.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late FocusBloc bloc;
  late MockTodoRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockRepository = MockTodoRepository();
    bloc = FocusBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('FocusBloc', () {
    test('initial state should be initial', () {
      expect(bloc.state, FocusState.initial());
    });

    blocTest<FocusBloc, FocusState>(
      'emits sessionsToday when LoadFocusSessionsEvent is added',
      build: () {
        when(() => mockRepository.getFocusSessionsCountForDay(any())).thenAnswer((_) async => 3);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadFocusSessionsEvent()),
      expect: () => [
        isA<FocusState>().having((s) => s.sessionsToday, 'sessionsToday', 3),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'emits isRunning: true when StartTimerEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(StartTimerEvent()),
      expect: () => [
        isA<FocusState>().having((s) => s.isRunning, 'isRunning', true),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'emits remainingTime decrement when TickEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const TickEvent(1499)),
      expect: () => [
        isA<FocusState>().having((s) => s.remainingTime, 'remainingTime', 1499),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'completes session and flips mode when timer reaches 0',
      build: () {
        when(() => mockRepository.completeFocusSession(any())).thenAnswer((_) async => {});
        when(() => mockRepository.getFocusSessionsCountForDay(any())).thenAnswer((_) async => 4);
        return bloc;
      },
      seed: () => FocusState.initial().copyWith(isWorking: true, remainingTime: 1),
      act: (bloc) => bloc.add(const TickEvent(0)),
      expect: () => [
        // Mode flips to break (isWorking: false), isRunning: false, remainingTime: 300 (default break)
        isA<FocusState>()
            .having((s) => s.isWorking, 'isWorking', false)
            .having((s) => s.isRunning, 'isRunning', false),
        // Plus whatever LoadFocusSessionsEvent emits
        isA<FocusState>()
            .having((s) => s.sessionsToday, 'sessionsToday', 4)
            .having((s) => s.isWorking, 'isWorking', false),
      ],
    );
    blocTest<FocusBloc, FocusState>(
      'emits isRunning: false when StopTimerEvent is added while running',
      build: () => bloc,
      seed: () => FocusState.initial().copyWith(isRunning: true),
      act: (bloc) => bloc.add(StopTimerEvent()),
      expect: () => [
        isA<FocusState>().having((s) => s.isRunning, 'isRunning', false),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'resets remainingTime to workDuration when ResetTimerEvent is added in work mode',
      build: () => bloc,
      seed: () => FocusState.initial().copyWith(remainingTime: 100, isRunning: true),
      act: (bloc) => bloc.add(ResetTimerEvent()),
      expect: () => [
        isA<FocusState>()
            .having((s) => s.isRunning, 'isRunning', false)
            .having((s) => s.remainingTime, 'remainingTime', FocusState.initial().workDuration),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'resets remainingTime to breakDuration when ResetTimerEvent is added in break mode',
      build: () => bloc,
      seed: () => FocusState.initial().copyWith(isWorking: false, remainingTime: 50),
      act: (bloc) => bloc.add(ResetTimerEvent()),
      expect: () => [
        isA<FocusState>()
            .having((s) => s.remainingTime, 'remainingTime', FocusState.initial().breakDuration),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'flips to break mode when ToggleModeEvent is added in work mode',
      build: () => bloc,
      act: (bloc) => bloc.add(ToggleModeEvent()),
      expect: () => [
        isA<FocusState>()
            .having((s) => s.isWorking, 'isWorking', false)
            .having((s) => s.isRunning, 'isRunning', false)
            .having((s) => s.remainingTime, 'remainingTime', FocusState.initial().breakDuration),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'flips to work mode when ToggleModeEvent is added in break mode',
      build: () => bloc,
      seed: () => FocusState.initial().copyWith(isWorking: false),
      act: (bloc) => bloc.add(ToggleModeEvent()),
      expect: () => [
        isA<FocusState>()
            .having((s) => s.isWorking, 'isWorking', true)
            .having((s) => s.remainingTime, 'remainingTime', FocusState.initial().workDuration),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'updates durations and sessionsTarget when ChangeDurationEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const ChangeDurationEvent(
        workDuration: 3000,
        breakDuration: 600,
        sessionsTarget: 4,
      )),
      expect: () => [
        isA<FocusState>()
            .having((s) => s.workDuration, 'workDuration', 3000)
            .having((s) => s.breakDuration, 'breakDuration', 600)
            .having((s) => s.sessionsTarget, 'sessionsTarget', 4)
            .having((s) => s.isRunning, 'isRunning', false)
            .having((s) => s.remainingTime, 'remainingTime', 3000), // work mode → remainingTime = workDuration
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'sets remainingTime to breakDuration when ChangeDurationEvent is added in break mode',
      build: () => bloc,
      seed: () => FocusState.initial().copyWith(isWorking: false),
      act: (bloc) => bloc.add(const ChangeDurationEvent(
        workDuration: 1500,
        breakDuration: 900,
        sessionsTarget: 6,
      )),
      expect: () => [
        isA<FocusState>()
            .having((s) => s.remainingTime, 'remainingTime', 900)
            .having((s) => s.breakDuration, 'breakDuration', 900),
      ],
    );

    blocTest<FocusBloc, FocusState>(
      'flips to work mode when TickEvent(0) is added in break mode without calling completeFocusSession',
      build: () => bloc,
      seed: () => FocusState.initial().copyWith(isWorking: false, remainingTime: 1),
      act: (bloc) => bloc.add(const TickEvent(0)),
      expect: () => [
        isA<FocusState>()
            .having((s) => s.isWorking, 'isWorking', true)
            .having((s) => s.isRunning, 'isRunning', false)
            .having((s) => s.remainingTime, 'remainingTime', FocusState.initial().workDuration),
      ],
    );

    test('close() cancels ticker subscription without error', () async {
      bloc.add(StartTimerEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      await bloc.close();
      // If we reach here without exception the subscription was cleanly cancelled
    });
  });
}
