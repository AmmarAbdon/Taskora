import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/todo/presentation/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:taskora/features/todo/presentation/bloc/navigation_bloc/navigation_event.dart';
import 'package:taskora/features/todo/presentation/bloc/navigation_bloc/navigation_state.dart';

void main() {
  group('NavigationBloc', () {
    test('initial state should be 0', () {
      expect(NavigationBloc().state, const NavigationState(0));
    });

    blocTest<NavigationBloc, NavigationState>(
      'emits correct index when ChangeTabEvent is added',
      build: () => NavigationBloc(),
      act: (bloc) => bloc.add(const ChangeTabEvent(2)),
      expect: () => [const NavigationState(2)],
    );
  });
}
