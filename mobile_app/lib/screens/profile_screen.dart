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
  bool _isSavingSubjects = false;
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _schoolOptions = availableSchoolNames();
  late final Set<String> _selectedSchools =
      (widget.account.selectedSchools.isEmpty
              ? [widget.account.schoolName]
              : widget.account.selectedSchools)
          .toSet();
  late final Set<String> _selectedInterests =
      widget.account.interests.toSet();
  late final Set<String> _selectedExpertise =
      widget.account.expertise.toSet();

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

  Future<void> _saveSubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final orderedSchools = _selectedSchools.toList()..sort();

    setState(() {
      _isSavingSubjects = true;
      _profilePhotoError = null;
      _profilePhotoMessage = null;
    });

    try {
      await user.updateDisplayName(
        AppAccount.encodeDisplayName(
          fullName: widget.account.fullName,
          accountType: widget.account.accountType,
          schoolName: orderedSchools.first,
          selectedSchools: orderedSchools,
          interests: _selectedInterests.toList(),
          expertise: _selectedExpertise.toList(),
          facultyPosition: widget.account.facultyPosition,
          isFacultyVerified: widget.account.isFacultyVerified,
        ),
      );
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser != null) {
        widget.onAccountChanged(AppAccount.fromFirebaseUser(refreshedUser));
      }
      if (!mounted) return;
      setState(() {
        _profilePhotoMessage = 'Schools, interests, and expertise updated.';
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _profilePhotoError =
            error.message ?? 'Unable to update interests and expertise.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingSubjects = false;
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
                            widget.account.isFaculty
                                ? (widget.account.facultyPosition ?? 'Board Member')
                                : widget.account.memberLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: brandAccentDark,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.account.email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (widget.account.selectedSchools.isEmpty
                                    ? [widget.account.schoolName]
                                    : widget.account.selectedSchools)
                                .join(', '),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: appTextMuted,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Interests: ${widget.account.interests.join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: appTextMuted,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Expertise: ${widget.account.expertise.join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: appTextMuted,
                                ),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schools, Interests & Expertise',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Update these anytime. BroncoBoost will keep using them alongside your past registrations and event history for better matching.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: appTextMuted,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 14),
                _ProfileMultiSchoolSelector(
                  schoolOptions: _schoolOptions,
                  selectedValues: _selectedSchools,
                  onToggle: (school) {
                    setState(() {
                      if (_selectedSchools.contains(school)) {
                        if (_selectedSchools.length > 1) {
                          _selectedSchools.remove(school);
                        }
                      } else {
                        _selectedSchools.add(school);
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
                _ProfileSubjectSelector(
                  title: 'Subjects of interest',
                  selectedValues: _selectedInterests,
                  onToggle: (subject) {
                    setState(() {
                      if (_selectedInterests.contains(subject)) {
                        if (_selectedInterests.length > 1) {
                          _selectedInterests.remove(subject);
                        }
                      } else {
                        _selectedInterests.add(subject);
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
                _ProfileSubjectSelector(
                  title: 'Areas of expertise',
                  selectedValues: _selectedExpertise,
                  onToggle: (subject) {
                    setState(() {
                      if (_selectedExpertise.contains(subject)) {
                        if (_selectedExpertise.length > 1) {
                          _selectedExpertise.remove(subject);
                        }
                      } else {
                        _selectedExpertise.add(subject);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: _isSavingSubjects ? null : _saveSubjects,
                    child: Text(
                      _isSavingSubjects ? 'Saving...' : 'Save subjects',
                    ),
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

class _ProfileSubjectSelector extends StatelessWidget {
  const _ProfileSubjectSelector({
    required this.title,
    required this.selectedValues,
    required this.onToggle,
  });

  final String title;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: schoolSubjects.map((subject) {
            final selected = selectedValues.contains(subject);
            return FilterChip(
              label: Text(subject),
              selected: selected,
              onSelected: (_) => onToggle(subject),
              selectedColor: softBlush,
              checkmarkColor: brandAccentDark,
              labelStyle: TextStyle(
                color: selected ? brandAccentDark : appTextMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: const BorderSide(color: mutedSurface),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProfileMultiSchoolSelector extends StatelessWidget {
  const _ProfileMultiSchoolSelector({
    required this.schoolOptions,
    required this.selectedValues,
    required this.onToggle,
  });

  final List<String> schoolOptions;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schools you want matched to',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: schoolOptions.map((school) {
            final selected = selectedValues.contains(school);
            return FilterChip(
              label: Text(school),
              selected: selected,
              onSelected: (_) => onToggle(school),
              selectedColor: softBlush,
              checkmarkColor: brandAccentDark,
              labelStyle: TextStyle(
                color: selected ? brandAccentDark : appTextMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: const BorderSide(color: mutedSurface),
            );
          }).toList(),
        ),
      ],
    );
  }
}
