import 'package:equatable/equatable.dart';
import 'package:taskora/core/services/profile_service.dart';

abstract class ProfileFormEvent extends Equatable {
  const ProfileFormEvent();
  @override
  List<Object?> get props => [];
}

class InitializeProfileFormEvent extends ProfileFormEvent {
  final UserProfile? profile;
  const InitializeProfileFormEvent(this.profile);
  @override
  List<Object?> get props => [profile];
}

class GenderChangedEvent extends ProfileFormEvent {
  final String gender;
  const GenderChangedEvent(this.gender);
  @override
  List<Object?> get props => [gender];
}

class ImageChangedEvent extends ProfileFormEvent {
  final String imagePath;
  const ImageChangedEvent(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}
