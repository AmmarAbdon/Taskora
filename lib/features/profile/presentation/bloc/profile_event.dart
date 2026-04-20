import 'package:equatable/equatable.dart';
import '../../../../core/services/profile_service.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;
  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class CompleteOnboardingEvent extends ProfileEvent {}

