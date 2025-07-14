import 'package:flutter_stock_scanner/features/import/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile(UserProfile profile);
  Future<bool> hasProfile();
}
