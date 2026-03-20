import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

const _brandGreen = Color(0xFF0B6E4F);
const _lightBackground = Color(0xFFF5F7F6);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BroncoBoostApp());
}

class BroncoBoostApp extends StatefulWidget {
  const BroncoBoostApp({super.key});

  @override
  State<BroncoBoostApp> createState() => _BroncoBoostAppState();
}

class _BroncoBoostAppState extends State<BroncoBoostApp> {
  late final Future<void> _firebaseInitialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  String? _authError;
  String? _authMessage;
  bool _isSubmitting = false;

  Future<void> _signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      setState(() {
        _authError = 'Enter both email and password.';
        _authMessage = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _authError = null;
      _authMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _authError = _friendlyAuthError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _createAccount({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.trim().isEmpty ||
        password.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      setState(() {
        _authError = 'Fill in every field to create your account.';
        _authMessage = null;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _authError = 'Passwords do not match.';
        _authMessage = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _authError = null;
      _authMessage = null;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user
          ?.updateDisplayName(_displayNameFromEmail(email.trim()));
      await credential.user?.reload();
      setState(() {
        _authMessage = 'Account created successfully.';
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        _authError = _friendlyAuthError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      setState(() {
        _authError = 'Enter your email first so we can send the reset link.';
        _authMessage = null;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      setState(() {
        _authMessage = 'Password reset email sent to ${email.trim()}.';
        _authError = null;
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        _authError = _friendlyAuthError(error);
        _authMessage = null;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    setState(() {
      _authError = null;
      _authMessage = null;
    });
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'That email already has an account.';
      case 'weak-password':
        return 'Use a stronger password with at least 6 characters.';
      case 'network-request-failed':
        return 'Network error while contacting Firebase.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Authentication yet.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  String _displayNameFromEmail(String email) {
    final prefix = email.split('@').first.trim();
    final parts = prefix
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Student';
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BroncoBoost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _brandGreen),
        scaffoldBackgroundColor: _lightBackground,
      ),
      home: FutureBuilder<void>(
        future: _firebaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppStateScreen(
              title: 'BroncoBoost',
              message: 'Connecting to Firebase...',
              loading: true,
            );
          }

          if (snapshot.hasError) {
            return AppStateScreen(
              title: 'Firebase setup incomplete',
              message: snapshot.error.toString(),
            );
          }

          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const AppStateScreen(
                  title: 'BroncoBoost',
                  message: 'Checking account session...',
                  loading: true,
                );
              }

              final user = authSnapshot.data;
              if (user == null) {
                return AuthScreen(
                  isSubmitting: _isSubmitting,
                  errorMessage: _authError,
                  infoMessage: _authMessage,
                  onSignIn: _signIn,
                  onCreateAccount: _createAccount,
                  onForgotPassword: _sendPasswordReset,
                );
              }

              final account = AppAccount.fromFirebaseUser(user);
              final state = SimpleRepository.stateFor(account);
              return BasicShell(
                account: account,
                state: state,
                onSignOut: _signOut,
              );
            },
          );
        },
      ),
    );
  }
}

class AppStateScreen extends StatelessWidget {
  const AppStateScreen({
    super.key,
    required this.title,
    required this.message,
    this.loading = false,
  });

  final String title;
  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) const CircularProgressIndicator(),
              if (loading) const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.isSubmitting,
    required this.errorMessage,
    required this.infoMessage,
    required this.onSignIn,
    required this.onCreateAccount,
    required this.onForgotPassword,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;
  final Future<void> Function({required String email, required String password})
      onSignIn;
  final Future<void> Function({
    required String email,
    required String password,
    required String confirmPassword,
  }) onCreateAccount;
  final Future<void> Function(String email) onForgotPassword;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _createMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    if (_createMode) {
      return widget.onCreateAccount(
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
      );
    }
    return widget.onSignIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BroncoBoost')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _createMode ? 'Create your account' : 'Sign in',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Track events, XP, avatar progress, and city unlocks.'),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (_createMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm password'),
              ),
            ],
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(widget.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ],
            if (widget.infoMessage != null) ...[
              const SizedBox(height: 12),
              Text(widget.infoMessage!,
                  style: const TextStyle(color: _brandGreen)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.isSubmitting ? null : _submit,
                child: Text(widget.isSubmitting
                    ? 'Please wait...'
                    : _createMode
                        ? 'Create account'
                        : 'Sign in'),
              ),
            ),
            TextButton(
              onPressed: widget.isSubmitting
                  ? null
                  : () => setState(() => _createMode = !_createMode),
              child: Text(_createMode
                  ? 'Already have an account? Sign in'
                  : 'Need an account? Create one'),
            ),
            TextButton(
              onPressed: widget.isSubmitting
                  ? null
                  : () => widget.onForgotPassword(_emailController.text),
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}

enum BasicTab { home, events, cities, profile }

class BasicShell extends StatefulWidget {
  const BasicShell({
    super.key,
    required this.account,
    required this.state,
    required this.onSignOut,
  });

  final AppAccount account;
  final SimpleState state;
  final Future<void> Function() onSignOut;

  @override
  State<BasicShell> createState() => _BasicShellState();
}

class _BasicShellState extends State<BasicShell> {
  BasicTab _selectedTab = BasicTab.home;
  late AppAccount _account = widget.account;

  void _showCheckInDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-in demo'),
        content: const Text(
            'This basic UI version keeps check-in as a simple demo action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = switch (_selectedTab) {
      BasicTab.home => HomeScreen(
          account: _account,
          state: widget.state,
          onCheckIn: _showCheckInDialog,
        ),
      BasicTab.events => EventsScreen(events: widget.state.events),
      BasicTab.cities => CitiesScreen(cities: widget.state.cities),
      BasicTab.profile => ProfileScreen(
          account: _account,
          state: widget.state,
          onSignOut: widget.onSignOut,
          onAccountChanged: (updatedAccount) {
            setState(() {
              _account = updatedAccount;
            });
          },
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('BroncoBoost')),
      body: screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: BasicTab.values.indexOf(_selectedTab),
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = BasicTab.values[index];
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.event_outlined), label: 'Events'),
          NavigationDestination(
              icon: Icon(Icons.location_city_outlined), label: 'Cities'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.account,
    required this.state,
    required this.onCheckIn,
  });

  final AppAccount account;
  final SimpleState state;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: Text(account.fullName),
            subtitle: Text('Rank #${state.rank} at CPP'),
            trailing: ProfileAvatar(account: account),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('XP', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${state.totalXp}',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: state.levelProgress),
                const SizedBox(height: 8),
                Text(
                    'Level ${state.level} • ${state.currentXpIntoLevel}/${state.xpForNextLevel} XP'),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Avatar / Character Progress'),
            subtitle: Text(
                '${state.avatarStage} • ${state.xpToNextStage} XP until next stage'),
            trailing: const Icon(Icons.pets),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onCheckIn,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Check in to event'),
        ),
        const SizedBox(height: 20),
        Text('Upcoming events', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...state.events.map(
          (event) => Card(
            child: ListTile(
              title: Text(event.name),
              subtitle: Text('${event.dateLabel} • ${event.location}'),
              trailing: Text('+${event.xpReward} XP'),
            ),
          ),
        ),
      ],
    );
  }
}

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key, required this.events});

  final List<EventItem> events;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          child: ListTile(
            title: Text(event.name),
            subtitle: Text('${event.dateLabel}\n${event.location}'),
            isThreeLine: true,
            trailing: Text('+${event.xpReward} XP'),
          ),
        );
      },
    );
  }
}

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key, required this.cities});

  final List<CityUnlock> cities;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return Card(
          child: ListTile(
            leading:
                Icon(city.unlocked ? Icons.check_circle : Icons.lock_outline),
            title: Text(city.name),
            subtitle: Text(
                city.unlocked ? 'Unlocked' : 'Travel here to unlock this city'),
          ),
        );
      },
    );
  }
}

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

  @override
  void dispose() {
    super.dispose();
  }

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
                TextButton.icon(
                  onPressed: _isUpdatingPhoto ? null : _pickProfilePhoto,
                  icon: Icon(
                    _isUpdatingPhoto ? Icons.hourglass_top : Icons.photo_camera,
                  ),
                  label: Text(
                    _isUpdatingPhoto ? 'Updating profile pic...' : 'Edit profile pic',
                  ),
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
                    style: const TextStyle(color: _brandGreen),
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
            trailing:
                Text('${widget.state.cities.where((city) => city.unlocked).length}'),
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

class AppAccount {
  const AppAccount({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
  });

  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;

  String get initials {
    final parts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory AppAccount.fromFirebaseUser(User user) {
    final displayName = user.displayName?.trim();
    final emailPrefix = user.email?.split('@').first.trim() ?? 'student';
    return AppAccount(
      uid: user.uid,
      fullName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : emailPrefix.replaceAll(RegExp(r'[._-]+'), ' '),
      email: user.email ?? '',
      photoUrl: user.photoURL?.trim().isEmpty ?? true ? null : user.photoURL,
    );
  }

  AppAccount copyWith({
    String? uid,
    String? fullName,
    String? email,
    Object? photoUrl = _noPhotoUrlOverride,
  }) {
    return AppAccount(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: identical(photoUrl, _noPhotoUrlOverride)
          ? this.photoUrl
          : photoUrl as String?,
    );
  }
}

const _noPhotoUrlOverride = Object();

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.account,
    this.radius = 20,
  });

  final AppAccount account;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = account.photoUrl?.trim();
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final imageProvider = hasPhoto ? _imageProvider(photoUrl) : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: _brandGreen.withValues(alpha: 0.12),
      backgroundImage: imageProvider,
      child: hasPhoto
          ? null
          : Text(
              account.initials,
              style: TextStyle(
                color: _brandGreen,
                fontWeight: FontWeight.w600,
                fontSize: radius * 0.75,
              ),
            ),
    );
  }

  ImageProvider? _imageProvider(String photoUrl) {
    final parsedUri = Uri.tryParse(photoUrl);
    final isRemote = parsedUri != null &&
        (parsedUri.scheme == 'http' || parsedUri.scheme == 'https');
    if (isRemote) {
      return NetworkImage(photoUrl);
    }
    if (photoUrl.isNotEmpty) {
      return FileImage(File(photoUrl));
    }
    return null;
  }
}

class EventItem {
  const EventItem({
    required this.name,
    required this.dateLabel,
    required this.location,
    required this.xpReward,
  });

  final String name;
  final String dateLabel;
  final String location;
  final int xpReward;
}

class CityUnlock {
  const CityUnlock({
    required this.name,
    required this.unlocked,
  });

  final String name;
  final bool unlocked;
}

class SimpleState {
  const SimpleState({
    required this.rank,
    required this.level,
    required this.totalXp,
    required this.currentXpIntoLevel,
    required this.xpForNextLevel,
    required this.avatarStage,
    required this.xpToNextStage,
    required this.events,
    required this.cities,
  });

  final int rank;
  final int level;
  final int totalXp;
  final int currentXpIntoLevel;
  final int xpForNextLevel;
  final String avatarStage;
  final int xpToNextStage;
  final List<EventItem> events;
  final List<CityUnlock> cities;

  double get levelProgress => currentXpIntoLevel / xpForNextLevel;
}

class SimpleRepository {
  static SimpleState stateFor(AppAccount account) {
    final seed =
        account.uid.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return SimpleState(
      rank: 12,
      level: 4 + (seed % 3),
      totalXp: 900 + (seed % 500),
      currentXpIntoLevel: 240 + (seed % 120),
      xpForNextLevel: 500,
      avatarStage: 'Rising Bronco',
      xpToNextStage: 140,
      events: const [
        EventItem(
          name: 'Startup Founder Panel',
          dateLabel: 'Today, 5:00 PM',
          location: 'Innovation Village',
          xpReward: 150,
        ),
        EventItem(
          name: 'CPP Networking Night',
          dateLabel: 'Fri, 6:30 PM',
          location: 'College of Business',
          xpReward: 120,
        ),
        EventItem(
          name: 'Hackathon Build Sprint',
          dateLabel: 'Sat, 10:00 AM',
          location: 'Library Lab',
          xpReward: 220,
        ),
      ],
      cities: const [
        CityUnlock(name: 'Pomona', unlocked: true),
        CityUnlock(name: 'Los Angeles', unlocked: true),
        CityUnlock(name: 'San Diego', unlocked: false),
        CityUnlock(name: 'San Francisco', unlocked: false),
      ],
    );
  }
}
