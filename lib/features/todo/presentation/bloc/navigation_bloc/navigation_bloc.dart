import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

/// Manages the state of the main bottom navigation bar.
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(0)) {
    on<ChangeTabEvent>((event, emit) => emit(NavigationState(event.index)));
  }
}
