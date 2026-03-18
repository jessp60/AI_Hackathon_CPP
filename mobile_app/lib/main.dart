import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InsightQuestApp());
}

class InsightQuestApp extends StatefulWidget {
  const InsightQuestApp({super.key});

  @override
  State<InsightQuestApp> createState() => _InsightQuestAppState();
}

class _InsightQuestAppState extends State<InsightQuestApp> {
  final InsightDemoState _state = InsightRepository.demoState();
  late final Future<void> _firebaseInitialization = _initializeFirebase();

  String? _authError;
  String? _authMessage;
  bool _isSubmitting = false;

  Future<void> _initializeFirebase() {
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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
      debugPrint('Firebase sign-in error: code=${error.code}, message=${error.message}');
      setState(() {
        _authError = _friendlyAuthError(error);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _createAccount({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty || confirmPassword.trim().isEmpty) {
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
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      await credential.user?.updateDisplayName(_displayNameFromEmail(email.trim()));
      await credential.user?.reload();
      setState(() {
        _authMessage = 'Account created successfully.';
      });
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase create-account error: code=${error.code}, message=${error.message}');
      setState(() {
        _authError = _friendlyAuthError(error);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      setState(() {
        _authError = 'Enter your email first so we know where to send the reset link.';
        _authMessage = null;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      setState(() {
        _authError = null;
        _authMessage = 'Password reset email sent to ${email.trim()}.';
      });
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase password-reset error: code=${error.code}, message=${error.message}');
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

  String _displayNameFromEmail(String email) {
    final String prefix = email.split('@').first.trim();
    final List<String> parts = prefix.split(RegExp(r'[._-]+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'Insight Student';
    }
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
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
        return 'Network error while contacting Firebase. Check the device connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Authentication yet.';
      default:
        final String message = error.message ?? 'Authentication failed.';
        return 'Firebase auth error (${error.code}): $message';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insight Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF184E4A),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF184E4A),
          secondary: const Color(0xFFC86F4A),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFFBF8F1),
        useMaterial3: true,
      ),
      home: FutureBuilder<void>(
        future: _firebaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingScreen(message: 'Connecting to Firebase...');
          }

          if (snapshot.hasError) {
            return ErrorScreen(
              title: 'Firebase setup incomplete',
              message: snapshot.error.toString(),
            );
          }

          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen(message: 'Checking account session...');
              }

              final User? user = authSnapshot.data;
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

              return HomeShell(
                state: _state,
                account: AppAccount.fromFirebaseUser(user),
                onSignOut: _signOut,
              );
            },
          );
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
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
  final Future<void> Function({
    required String email,
    required String password,
  }) onSignIn;
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isCreateMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    if (_isCreateMode) {
      return widget.onCreateAccount(
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4E5C2),
              Color(0xFFF7F4EA),
              Color(0xFFE0F0F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insight Quest',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isCreateMode
                              ? 'Create a secure account with email and password.'
                              : 'Sign in with your email and password to keep your events, badges, city unlocks, and reminders synced.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (_isCreateMode) ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                        if (widget.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            widget.errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.red.shade700,
                                ),
                          ),
                        ],
                        if (widget.infoMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            widget.infoMessage!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF184E4A),
                                ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: widget.isSubmitting ? null : _submit,
                          child: Text(
                            widget.isSubmitting
                                ? 'Please wait...'
                                : _isCreateMode
                                    ? 'Create account'
                                    : 'Sign in',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: widget.isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _isCreateMode = !_isCreateMode;
                                  });
                                },
                          child: Text(
                            _isCreateMode
                                ? 'Already have an account? Sign in'
                                : 'Need an account? Create one',
                          ),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.state,
    required this.account,
    required this.onSignOut,
  });

  final InsightDemoState state;
  final AppAccount account;
  final Future<void> Function() onSignOut;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      CalendarScreen(state: widget.state, account: widget.account),
      CitiesScreen(state: widget.state, account: widget.account),
      ProfileScreen(
        state: widget.state,
        account: widget.account,
        onSignOut: widget.onSignOut,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4E5C2),
              Color(0xFFF7F4EA),
              Color(0xFFE0F0F0),
            ],
          ),
        ),
        child: SafeArea(child: screens[_selectedIndex]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Cities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({
    super.key,
    required this.state,
    required this.account,
  });

  final InsightDemoState state;
  final AppAccount account;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        HeroCard(
          eyebrow: 'Firebase Auth Connected',
          title: 'Welcome back, ${account.firstName}.',
          body: 'Your event history and rewards are now tied to your Firebase account.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(label: 'Level', value: '${state.studentLevel}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(label: 'Upcoming', value: '${state.events.length}'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final event in state.events) ...[
          EventCard(event: event),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({
    super.key,
    required this.state,
    required this.account,
  });

  final InsightDemoState state;
  final AppAccount account;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        HeroCard(
          eyebrow: 'Travel Map',
          title: 'Unlock metro regions as you go',
          body: '${account.email} is your shared account for city unlocks in the app and extension.',
        ),
        const SizedBox(height: 16),
        for (final region in state.regions) ...[
          RegionCard(region: region),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.state,
    required this.account,
    required this.onSignOut,
  });

  final InsightDemoState state;
  final AppAccount account;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AccountCard(account: account, onSignOut: onSignOut),
        const SizedBox(height: 16),
        HeroCard(
          eyebrow: 'Student Profile',
          title: state.studentName,
          body: 'Marketing explorer on a ${state.attendanceStreak}-event streak.',
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${state.studentLevel}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: state.levelProgress, minHeight: 10),
                const SizedBox(height: 10),
                Text(
                  '${state.currentXp} XP of ${state.nextLevelXp} XP to the next reward drop',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(label: 'Badges', value: '${state.badges.length}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Cities',
                        value: '${state.regions.where((r) => r.isUnlocked).length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlocked Badges',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                for (final badge in state.badges) ...[
                  Text('• $badge'),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.onSignOut,
  });

  final AppAccount account;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF184E4A),
              foregroundColor: Colors.white,
              child: Text(account.avatarInitials),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onSignOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF3E2B8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF184E4A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final InsightEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${event.date} • ${event.region}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF184E4A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Nearby schools: ${event.nearbyUniversities}'),
            const SizedBox(height: 4),
            Text(
              'Course alignment: ${event.courseAlignment}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                RewardChip(label: '+${event.rewardXp} XP'),
                RewardChip(label: '+${event.rewardCoins} coins'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RegionCard extends StatelessWidget {
  const RegionCard({super.key, required this.region});

  final RegionProgress region;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: region.isUnlocked ? const Color(0xFFE2F0EC) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              region.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              region.isUnlocked
                  ? 'Unlocked • ${region.badgeName}'
                  : 'Locked • Visit or attend a local event to unlock',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF184E4A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text('Featured speaker: ${region.featuredSpeaker}'),
            const SizedBox(height: 4),
            Text(
              region.regionFlavor,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class RewardChip extends StatelessWidget {
  const RewardChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E2B8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF184E4A),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class AppAccount {
  const AppAccount({
    required this.fullName,
    required this.email,
    required this.avatarInitials,
  });

  factory AppAccount.fromFirebaseUser(User user) {
    final String email = user.email ?? 'unknown@insight.quest';
    final String fullName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : _displayNameFromEmail(email);
    return AppAccount(
      fullName: fullName,
      email: email,
      avatarInitials: _initialsFromEmail(email, fullName),
    );
  }

  static String _displayNameFromEmail(String email) {
    final String prefix = email.split('@').first.trim();
    final List<String> parts = prefix.split(RegExp(r'[._-]+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'Insight Student';
    }
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static String _initialsFromEmail(String email, String fullName) {
    final List<String> parts = fullName.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      return parts.take(2).map((part) => part[0]).join().toUpperCase();
    }
    return email.substring(0, email.length.clamp(0, 2)).toUpperCase();
  }

  String get firstName => fullName.split(' ').first;

  final String fullName;
  final String email;
  final String avatarInitials;
}

class InsightEvent {
  const InsightEvent({
    required this.title,
    required this.date,
    required this.region,
    required this.nearbyUniversities,
    required this.courseAlignment,
    required this.rewardXp,
    required this.rewardCoins,
  });

  final String title;
  final String date;
  final String region;
  final String nearbyUniversities;
  final String courseAlignment;
  final int rewardXp;
  final int rewardCoins;
}

class RegionProgress {
  const RegionProgress({
    required this.name,
    required this.isUnlocked,
    required this.badgeName,
    required this.featuredSpeaker,
    required this.regionFlavor,
  });

  final String name;
  final bool isUnlocked;
  final String badgeName;
  final String featuredSpeaker;
  final String regionFlavor;
}

class InsightDemoState {
  const InsightDemoState({
    required this.studentName,
    required this.studentLevel,
    required this.currentXp,
    required this.nextLevelXp,
    required this.levelProgress,
    required this.attendanceStreak,
    required this.badges,
    required this.events,
    required this.regions,
  });

  final String studentName;
  final int studentLevel;
  final int currentXp;
  final int nextLevelXp;
  final double levelProgress;
  final int attendanceStreak;
  final List<String> badges;
  final List<InsightEvent> events;
  final List<RegionProgress> regions;
}

class InsightRepository {
  static InsightDemoState demoState() {
    return const InsightDemoState(
      studentName: 'Jordan Rivera',
      studentLevel: 4,
      currentXp: 420,
      nextLevelXp: 600,
      levelProgress: 0.70,
      attendanceStreak: 3,
      badges: [
        'First Check-In',
        'Hackathon Helper',
        'Traveler: San Diego',
        'Traveler: Los Angeles',
      ],
      events: [
        InsightEvent(
          title: 'Insight Portland Student Mixer',
          date: 'Apr 16, 2026',
          region: 'Portland',
          nearbyUniversities: 'Portland State, U of Oregon, Oregon State',
          courseAlignment: 'Marketing Research, Consumer Behavior',
          rewardXp: 120,
          rewardCoins: 35,
        ),
        InsightEvent(
          title: 'Insight San Diego Analytics Night',
          date: 'May 14, 2026',
          region: 'San Diego',
          nearbyUniversities: 'SDSU, USD, UC San Diego',
          courseAlignment: 'Analytics capstones, project presentations',
          rewardXp: 140,
          rewardCoins: 40,
        ),
        InsightEvent(
          title: 'Insight Los Angeles Summer Launch',
          date: 'Jun 18, 2026',
          region: 'Los Angeles',
          nearbyUniversities: 'UCLA, USC, Cal Poly Pomona, LMU',
          courseAlignment: 'Summer intensives, boot camps',
          rewardXp: 180,
          rewardCoins: 50,
        ),
        InsightEvent(
          title: 'Insight Bay Area Innovation Session',
          date: 'Jul 23, 2026',
          region: 'San Francisco',
          nearbyUniversities: 'USF, SFSU, Berkeley Haas, Santa Clara',
          courseAlignment: 'Executive education, certificate programs',
          rewardXp: 160,
          rewardCoins: 45,
        ),
        InsightEvent(
          title: 'Insight Seattle Welcome Week',
          date: 'Aug 20, 2026',
          region: 'Seattle',
          nearbyUniversities: 'UW Foster, Seattle U, WSU',
          courseAlignment: 'New student orientations, welcome week',
          rewardXp: 125,
          rewardCoins: 35,
        ),
      ],
      regions: [
        RegionProgress(
          name: 'Los Angeles',
          isUnlocked: true,
          badgeName: 'Metro Connector',
          featuredSpeaker: 'Donna Flynn',
          regionFlavor:
              'A strong hub for research operations, brand storytelling, and student networking.',
        ),
        RegionProgress(
          name: 'San Diego',
          isUnlocked: true,
          badgeName: 'Coastal Analyst',
          featuredSpeaker: 'Monica Voss',
          regionFlavor:
              'A city focused on platform insights, client success, and data-driven storytelling.',
        ),
        RegionProgress(
          name: 'Portland',
          isUnlocked: false,
          badgeName: 'Northwest Strategist',
          featuredSpeaker: 'Katie Nelson',
          regionFlavor:
              'A region shaped by brand strategy, optimization, and member engagement.',
        ),
        RegionProgress(
          name: 'San Francisco',
          isUnlocked: false,
          badgeName: 'Innovation Scout',
          featuredSpeaker: 'Katrina Noelle',
          regionFlavor:
              'A destination for qualitative research, analytics, and insight-led decision making.',
        ),
        RegionProgress(
          name: 'Seattle',
          isUnlocked: false,
          badgeName: 'Research Trailblazer',
          featuredSpeaker: 'Greg Carter',
          regionFlavor:
              'A practical research community with strength in focus groups and interviews.',
        ),
        RegionProgress(
          name: 'Ventura / Thousand Oaks',
          isUnlocked: false,
          badgeName: 'Community Builder',
          featuredSpeaker: 'Travis Miller',
          regionFlavor:
              'A relationship-driven region blending innovation, sales, and customer experience.',
        ),
        RegionProgress(
          name: 'Orange County / Long Beach',
          isUnlocked: false,
          badgeName: 'Signal Seeker',
          featuredSpeaker: 'Rob Kaiser',
          regionFlavor:
              'A creative analytics corridor with room for marketing science and growth.',
        ),
      ],
    );
  }
}
