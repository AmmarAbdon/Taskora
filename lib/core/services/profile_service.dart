import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final int age;
  final String gender;
  final String? imagePath;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'imagePath': imagePath,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'],
    age: json['age'],
    gender: json['gender'],
    imagePath: json['imagePath'],
  );
}

class ProfileService {
  final SharedPreferences _prefs;
  static const String _key = 'user_profile';
  static const String _onboardingKey = 'onboarding_complete';

  ProfileService(this._prefs);

  UserProfile? getProfile() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return null;
    return UserProfile.fromJson(jsonDecode(jsonString));
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  bool isOnboardingComplete() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  bool isProfileComplete() {
    return getProfile() != null;
  }
}
