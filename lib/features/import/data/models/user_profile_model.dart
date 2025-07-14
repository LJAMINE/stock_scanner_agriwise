 
import 'package:flutter_stock_scanner/features/import/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.name,
    required super.email,
    super.avatarBase64,
    super.phone,
    super.bio,
  });

  // Convert from JSON (SharedPreferences)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarBase64: json['avatarBase64'],
      phone: json['phone'],
      bio: json['bio'],
    );
  }

  // Convert to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarBase64': avatarBase64,
      'phone': phone,
      'bio': bio,
    };
  }

  // Default profile for testing
  static const UserProfileModel defaultProfile = UserProfileModel(
    name: 'Amine lm',
    email: 'amine@gmail.com',
    bio: 'Stock Manager',
  );

  // Create a copy with updated fields
  UserProfileModel copyWith({
    String? name,
    String? email,
    String? avatarBase64,
    String? phone,
    String? bio,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
    );
  }
}