import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskora/core/services/profile_service.dart';

void main() {
  late ProfileService profileService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    profileService = ProfileService(prefs);
  });

  group('ProfileService', () {
    // --- getProfile ---
    test('getProfile returns null when no profile is saved', () {
      expect(profileService.getProfile(), isNull);
    });

    test('getProfile returns a UserProfile after saveProfile is called', () async {
      final profile = UserProfile(name: 'Alice', age: 30, gender: 'Female');
      await profileService.saveProfile(profile);

      final loaded = profileService.getProfile();

      expect(loaded, isNotNull);
      expect(loaded!.name, 'Alice');
      expect(loaded.age, 30);
      expect(loaded.gender, 'Female');
      expect(loaded.imagePath, isNull);
    });

    test('getProfile returns profile with imagePath when saved with one', () async {
      final profile = UserProfile(
        name: 'Bob',
        age: 25,
        gender: 'Male',
        imagePath: '/path/to/image.jpg',
      );
      await profileService.saveProfile(profile);

      final loaded = profileService.getProfile();
      expect(loaded!.imagePath, '/path/to/image.jpg');
    });

    test('saveProfile overwrites previous profile', () async {
      await profileService.saveProfile(UserProfile(name: 'Old', age: 20, gender: 'Other'));
      await profileService.saveProfile(UserProfile(name: 'New', age: 22, gender: 'Male'));

      final loaded = profileService.getProfile();
      expect(loaded!.name, 'New');
      expect(loaded.age, 22);
    });

    // --- isProfileComplete ---
    test('isProfileComplete returns false when no profile is saved', () {
      expect(profileService.isProfileComplete(), isFalse);
    });

    test('isProfileComplete returns true after a profile is saved', () async {
      await profileService.saveProfile(UserProfile(name: 'Alice', age: 30, gender: 'Female'));
      expect(profileService.isProfileComplete(), isTrue);
    });

    // --- isOnboardingComplete ---
    test('isOnboardingComplete returns false before setOnboardingComplete is called', () {
      expect(profileService.isOnboardingComplete(), isFalse);
    });

    test('isOnboardingComplete returns true after setOnboardingComplete is called', () async {
      await profileService.setOnboardingComplete();
      expect(profileService.isOnboardingComplete(), isTrue);
    });
  });

  group('UserProfile', () {
    test('toJson and fromJson are symmetric', () {
      final profile = UserProfile(
        name: 'Charlie',
        age: 35,
        gender: 'Male',
        imagePath: '/images/charlie.png',
      );

      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.name, profile.name);
      expect(restored.age, profile.age);
      expect(restored.gender, profile.gender);
      expect(restored.imagePath, profile.imagePath);
    });

    test('fromJson handles null imagePath correctly', () {
      final json = {'name': 'Dana', 'age': 28, 'gender': 'Female', 'imagePath': null};
      final profile = UserProfile.fromJson(json);
      expect(profile.imagePath, isNull);
    });
  });
}
