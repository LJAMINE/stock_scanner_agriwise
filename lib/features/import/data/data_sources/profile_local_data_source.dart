import 'package:flutter_stock_scanner/features/import/data/models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getProfile();
  Future<void> saveProfile(UserProfileModel profile);
  Future<bool> hasProfile();
}