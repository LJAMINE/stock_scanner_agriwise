class UserProfile {
  final String name;
  final String email;
  final String? avatarBase64; // For profile picture
  final String? phone; // Optional
  final String? bio; // Optional

  const UserProfile({
    required this.name,
    required this.email,
    this.avatarBase64,
    this.phone,
    this.bio,
  });

   String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
