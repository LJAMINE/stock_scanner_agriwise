import 'package:flutter_stock_scanner/features/import/data/data_sources/profile_local_data_source.dart';
import 'package:flutter_stock_scanner/features/import/data/models/user_profile_model.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/user_profile.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/ProfileRepository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<UserProfile> getProfile() async {
    return await localDataSource.getProfile();
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    // Convert UserProfile to UserProfileModel for data layer
    final profileModel = UserProfileModel(
      name: profile.name,
      email: profile.email,
      avatarBase64: profile.avatarBase64,
      phone: profile.phone,
      bio: profile.bio,
    );
    await localDataSource.saveProfile(profileModel);
  }

  @override
  Future<bool> hasProfile() async {
    return await localDataSource.hasProfile();
  }
}
