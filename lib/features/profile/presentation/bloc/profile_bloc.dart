import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/profile_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;

  ProfileBloc(this.profileService) : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = profileService.getProfile();
        if (profile != null) {
          emit(ProfileLoaded(profile));
        } else {
          emit(const ProfileError('Profile not found'));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        await profileService.saveProfile(event.profile);
        emit(ProfileUpdateSuccess(event.profile));
        // Immediately emit Loaded state with the new profile
        emit(ProfileLoaded(event.profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<CompleteOnboardingEvent>((event, emit) async {
      try {
        await profileService.setOnboardingComplete();
        emit(OnboardingCompleteSuccess());
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
