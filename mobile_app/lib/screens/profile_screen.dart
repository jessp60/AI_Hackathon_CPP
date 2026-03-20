import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_models.dart';
import '../theme_constants.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.account,
    required this.state,
    required this.onSignOut,
    required this.onAccountChanged,
  });

  final AppAccount account;
  final SimpleState state;
  final Future<void> Function() onSignOut;
  final ValueChanged<AppAccount> onAccountChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profilePhotoMessage;
  String? _profilePhotoError;
  bool _isUpdatingPhoto = false;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isUpdatingPhoto = true;
      _profilePhotoError = null;
      _profilePhotoMessage = null;
    });

    try {
      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (selectedImage == null) {
        if (!mounted) return;
        setState(() {
          _isUpdatingPhoto = false;
        });
        return;
      }

      await user.updatePhotoURL(selectedImage.path);
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser != null) {
        widget.onAccountChanged(AppAccount.fromFirebaseUser(refreshedUser));
      }
      if (!mounted) return;
      setState(() {
        _profilePhotoMessage = 'Profile picture updated.';
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _profilePhotoError = error.message ?? 'Unable to update profile photo.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profilePhotoError = 'Unable to open your photo library right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPhoto = false;
        });
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isUpdatingPhoto = true;
      _profilePhotoError = null;
      _profilePhotoMessage = null;
    });

    try {
      await user.updatePhotoURL(null);
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser != null) {
        widget.onAccountChanged(AppAccount.fromFirebaseUser(refreshedUser));
      }
      if (!mounted) return;
      setState(() {
        _profilePhotoMessage = 'Profile picture removed.';
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _profilePhotoError = error.message ?? 'Unable to remove profile photo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileAvatar(
                          account: widget.account,
                          radius: 32,
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _isUpdatingPhoto ? null : _pickProfilePhoto,
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.account.fullName),
                          const SizedBox(height: 4),
                          Text(
                            widget.account.email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isUpdatingPhoto)
                  Text(
                    'Updating profile pic...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (_profilePhotoError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _profilePhotoError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                if (_profilePhotoMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _profilePhotoMessage!,
                    style: const TextStyle(color: brandAccent),
                  ),
                ],
                if ((widget.account.photoUrl ?? '').isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _isUpdatingPhoto ? null : _removeProfilePhoto,
                      child: const Text('Remove profile pic'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Total XP'),
            trailing: Text('${widget.state.totalXp}'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Unlocked cities'),
            trailing: Text(
              '${widget.state.cities.where((city) => city.unlocked).length}',
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Avatar stage'),
            trailing: Text(widget.state.avatarStage),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: widget.onSignOut,
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
