import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import 'profile_local_data_source.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String profileKey = 'user_profile';

  @override
  Future<UserProfileModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(profileKey);

    if (profileJson != null) {
      final Map<String, dynamic> profileMap = jsonDecode(profileJson);
      return UserProfileModel.fromJson(profileMap);
    }

    // Return default profile if none exists
    return UserProfileModel.defaultProfile;
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(profileKey, profileJson);
  }

  @override
  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(profileKey);
  }
}
