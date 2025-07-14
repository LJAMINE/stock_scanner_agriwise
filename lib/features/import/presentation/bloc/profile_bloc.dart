import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/user_profile.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/ProfileRepository.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc(this.profileRepository) : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ResetProfileEvent>(_onResetProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      final hasProfile = await profileRepository.hasProfile();

      if (!hasProfile) {
        emit(const ProfileEmpty());
        return;
      }

      final profile = await profileRepository.getProfile();
      emit(ProfileLoaded(profile, hasProfile: true));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileUpdating(event.profile));

      await profileRepository.updateProfile(event.profile);

      emit(ProfileUpdated(event.profile));

      // After updating, load the updated profile
      add(const LoadProfileEvent());
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> _onResetProfile(
    ResetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Create a default empty profile
      final defaultProfile = UserProfile(
        name: '',
        email: '',
        avatarBase64: null,
        phone: null,
        bio: null,
      );

      await profileRepository.updateProfile(defaultProfile);
      emit(const ProfileEmpty());
    } catch (e) {
      emit(ProfileError('Failed to reset profile: ${e.toString()}'));
    }
  }
}
