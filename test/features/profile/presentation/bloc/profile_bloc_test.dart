import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskora/core/services/profile_service.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_event.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_state.dart';

class MockProfileService extends Mock implements ProfileService {}

class FakeUserProfile extends Fake implements UserProfile {}

void main() {
  late ProfileBloc bloc;
  late MockProfileService mockProfileService;

  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  setUp(() {
    mockProfileService = MockProfileService();
    bloc = ProfileBloc(mockProfileService);
  });

  tearDown(() {
    bloc.close();
  });

  final tProfile = UserProfile(name: 'Test', age: 25, gender: 'Male', imagePath: null);

  group('ProfileBloc', () {
    test('initial state should be ProfileInitial', () {
      expect(bloc.state, ProfileInitial());
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when LoadProfileEvent is successful',
      build: () {
        when(() => mockProfileService.getProfile()).thenReturn(tProfile);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProfileEvent()),
      expect: () => [
        ProfileLoading(),
        ProfileLoaded(tProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when profile is null',
      build: () {
        when(() => mockProfileService.getProfile()).thenReturn(null);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProfileEvent()),
      expect: () => [
        ProfileLoading(),
        const ProfileError('Profile not found'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileUpdateSuccess, ProfileLoaded] when update is successful',
      build: () {
        when(() => mockProfileService.saveProfile(any())).thenAnswer((_) async => {});
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateProfileEvent(tProfile)),
      expect: () => [
        ProfileLoading(),
        ProfileUpdateSuccess(tProfile),
        ProfileLoaded(tProfile),
      ],
    );
  });
}
