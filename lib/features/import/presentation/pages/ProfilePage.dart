import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/core/util/imagebase64.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/user_profile.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isEditing = false;
  String? _selectedAvatarBase64;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _populateFields(UserProfile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _bioController.text = profile.bio ?? '';
    _selectedAvatarBase64 = profile.avatarBase64;
  }

  void _selectAvatar() async {
    try {
      final avatarBase64 = await pickImageAsBase64();
      if (avatarBase64 != null) {
        setState(() {
          _selectedAvatarBase64 = avatarBase64;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar selected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select avatar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        avatarBase64: _selectedAvatarBase64,
      );

      context.read<ProfileBloc>().add(UpdateProfileEvent(profile));
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Edit Profile' : 'My Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF356033),
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF356033),
                  Color(0xFF2D5129),
                ],
              ),
            ),
          ),
          actions: [
            if (!_isEditing)
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit_rounded, size: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              ),
            if (_isEditing) ...[
              Container(
                margin: EdgeInsets.only(right: 4),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.check_rounded, size: 20),
                  ),
                  onPressed: _saveProfile,
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.close_rounded, size: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                    // Reload profile to reset fields
                    context.read<ProfileBloc>().add(const LoadProfileEvent());
                  },
                ),
              ),
            ],
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF356033).withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text(state.message),
                      ],
                    ),
                    backgroundColor: Colors.red[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(16),
                  ),
                );
              } else if (state is ProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                    ),
                  );
                }

                if (state is ProfileError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading profile',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ProfileBloc>()
                                .add(const LoadProfileEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                UserProfile? profile;
                bool shouldStartEditing = false;

                if (state is ProfileLoaded) {
                  profile = state.profile;
                  if (!_isEditing) {
                    _populateFields(profile);
                  }
                } else if (state is ProfileEmpty) {
                  // Create default empty profile for editing
                  profile = UserProfile(
                    name: '',
                    email: '',
                    avatarBase64: null,
                    phone: null,
                    bio: null,
                  );
                  if (!_isEditing) {
                    _populateFields(profile);
                    shouldStartEditing = true; // Flag to start editing mode
                  }
                }

                // Use post frame callback to set editing state without triggering setState during build
                if (shouldStartEditing) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  });
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar Section
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: (_selectedAvatarBase64 ??
                                            profile?.avatarBase64) !=
                                        null
                                    ? MemoryImage(base64Decode(
                                        _selectedAvatarBase64 ??
                                            profile!.avatarBase64!))
                                    : null,
                                child: (_selectedAvatarBase64 ??
                                            profile?.avatarBase64) ==
                                        null
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4CAF50),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _selectAvatar,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bio Field
                        TextFormField(
                          controller: _bioController,
                          enabled: _isEditing,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Bio (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.info_outline),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save Button (when editing)
                        if (_isEditing)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save Profile',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
