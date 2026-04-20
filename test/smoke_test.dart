import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_state.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_event.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_state.dart';
import 'package:taskora/features/todo/presentation/bloc/todo_event.dart';
import 'package:taskora/features/todo/presentation/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:taskora/features/todo/presentation/bloc/navigation_bloc/navigation_state.dart';
import 'package:taskora/features/todo/presentation/bloc/navigation_bloc/navigation_event.dart';
import 'package:taskora/features/todo/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'package:taskora/features/todo/presentation/bloc/focus_bloc/focus_state.dart';
import 'package:taskora/features/todo/presentation/bloc/focus_bloc/focus_event.dart';
import 'package:taskora/features/todo/presentation/pages/main_page.dart';
import 'package:taskora/features/todo/presentation/pages/home_page.dart';
import 'package:taskora/features/todo/presentation/pages/statistics_page.dart';
import 'package:taskora/features/todo/presentation/pages/focus_mode_page.dart';
import 'package:taskora/main.dart'; // For themeNotifier

class MockTodoBloc extends MockBloc<TodoEvent, TodoState> implements TodoBloc {}
class MockNavigationBloc extends MockBloc<NavigationEvent, NavigationState> implements NavigationBloc {}
class MockFocusBloc extends MockBloc<FocusEvent, FocusState> implements FocusBloc {}
class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

void main() {
  late MockTodoBloc mockTodoBloc;
  late MockNavigationBloc mockNavigationBloc;
  late MockFocusBloc mockFocusBloc;
  late MockProfileBloc mockProfileBloc;

  setUp(() {
    themeNotifier = ValueNotifier(ThemeMode.light);
    mockTodoBloc = MockTodoBloc();
    mockNavigationBloc = MockNavigationBloc();
    mockFocusBloc = MockFocusBloc();
    mockProfileBloc = MockProfileBloc();

    // Default states
    when(() => mockNavigationBloc.state).thenReturn(const NavigationState(0));
    when(() => mockTodoBloc.state).thenReturn(TodoInitial());
    when(() => mockFocusBloc.state).thenReturn(FocusState.initial());
    when(() => mockProfileBloc.state).thenReturn(ProfileInitial());

    // Stream stubs for BLoC
    whenListen(mockNavigationBloc, Stream.fromIterable([const NavigationState(0)]));
    whenListen(mockTodoBloc, Stream.fromIterable([TodoInitial()]));
    whenListen(mockFocusBloc, Stream.fromIterable([FocusState.initial()]));
    whenListen(mockProfileBloc, Stream.fromIterable([ProfileInitial()]));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
          BlocProvider<TodoBloc>.value(value: mockTodoBloc),
          BlocProvider<FocusBloc>.value(value: mockFocusBloc),
          BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
        ],
        child: const MainPage(),
      ),
    );
  }

  group('MainPage Smoke Tests', () {
    testWidgets('should render HomePage initially', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('My Tasks'), findsOneWidget);
    });

    testWidgets('should render StatisticsPage when built directly', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<TodoBloc>.value(value: mockTodoBloc),
              BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
              BlocProvider<FocusBloc>.value(value: mockFocusBloc),
              BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
            ],
            child: const StatisticsPage(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(StatisticsPage), findsOneWidget);
    });

    testWidgets('should render FocusModePage when built directly', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<TodoBloc>.value(value: mockTodoBloc),
              BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
              BlocProvider<FocusBloc>.value(value: mockFocusBloc),
              BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
            ],
            child: const FocusModePage(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(FocusModePage), findsOneWidget);
    });
  });
}
