import 'package:equatable/equatable.dart';

class ProfileFormState extends Equatable {
  final String gender;
  final String? imagePath;

  const ProfileFormState({required this.gender, this.imagePath});

  factory ProfileFormState.initial() => const ProfileFormState(gender: 'Male');

  ProfileFormState copyWith({String? gender, String? imagePath}) {
    return ProfileFormState(
      gender: gender ?? this.gender,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [gender, imagePath];
}
