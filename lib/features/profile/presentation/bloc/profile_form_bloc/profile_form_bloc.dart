import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_form_event.dart';
import 'profile_form_state.dart';

class ProfileFormBloc extends Bloc<ProfileFormEvent, ProfileFormState> {
  ProfileFormBloc() : super(ProfileFormState.initial()) {
    on<InitializeProfileFormEvent>((event, emit) {
      if (event.profile != null) {
        emit(ProfileFormState(
          gender: event.profile!.gender,
          imagePath: event.profile!.imagePath,
        ));
      }
    });

    on<GenderChangedEvent>((event, emit) => emit(state.copyWith(gender: event.gender)));
    on<ImageChangedEvent>((event, emit) => emit(state.copyWith(imagePath: event.imagePath)));
  }
}
