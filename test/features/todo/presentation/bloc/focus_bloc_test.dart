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
  });
}
