import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/app_models.dart';
import 'screens/badges_screen.dart';
import 'screens/farm_screen.dart';
import 'screens/home_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/qr_screen.dart';
import 'theme_constants.dart';

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
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: brandAccent,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFDDB9C1),
          onPrimaryContainer: appText,
          secondary: Color(0xFFB68672),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFEBD8CF),
          onSecondaryContainer: appText,
          error: Color(0xFFB3261E),
          onError: Colors.white,
          errorContainer: Color(0xFFF9DEDC),
          onErrorContainer: Color(0xFF410E0B),
          surface: appSurface,
          onSurface: appText,
          onSurfaceVariant: appTextMuted,
          outline: Color(0xFFB8AAA3),
          outlineVariant: mutedSurface,
          shadow: Colors.black12,
          scrim: Colors.black54,
          inverseSurface: appText,
          onInverseSurface: appSurface,
          inversePrimary: Color(0xFFE6C1C8),
          surfaceTint: brandAccent,
        ),
        scaffoldBackgroundColor: appBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: appBackground,
          foregroundColor: appText,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: appSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: mutedSurface),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: appSurface,
          labelStyle: const TextStyle(color: appTextMuted),
          hintStyle: const TextStyle(color: appTextMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: mutedSurface),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: mutedSurface),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: brandAccent, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: brandAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: brandAccentDark,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: appSurface,
          indicatorColor: const Color(0xFFE6C9CF),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              height: 1.1,
              color: selected ? brandAccentDark : appTextMuted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? brandAccentDark : appTextMuted,
            );
          }),
        ),
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
      appBar: AppBar(),
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
                  style: const TextStyle(color: brandAccent)),
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

enum BasicTab { home, farm, qr, badges, leaderboard }

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

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: ProfileScreen(
            account: _account,
            state: widget.state,
            onSignOut: widget.onSignOut,
            onAccountChanged: (updatedAccount) {
              setState(() {
                _account = updatedAccount;
              });
            },
          ),
        ),
      ),
    );
  }

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

  void _openFarm() {
    setState(() {
      _selectedTab = BasicTab.farm;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = switch (_selectedTab) {
      BasicTab.home => HomeScreen(
          account: _account,
          state: widget.state,
          onCheckIn: _showCheckInDialog,
          onOpenFarm: _openFarm,
          onOpenProfile: _openProfile,
        ),
      BasicTab.farm => FarmScreen(state: widget.state),
      BasicTab.qr => QrScreen(onScanPressed: _showCheckInDialog),
      BasicTab.badges => BadgesScreen(state: widget.state),
      BasicTab.leaderboard => LeaderboardScreen(
          account: _account,
          state: widget.state,
        ),
    };

    return Scaffold(
      body: SafeArea(child: screen),
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
              icon: Icon(Icons.agriculture_outlined), label: 'Farm'),
          NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined), label: 'QR'),
          NavigationDestination(
              icon: Icon(Icons.workspace_premium_outlined), label: 'Badges'),
          NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined), label: 'Leaderboard'),
        ],
      ),
    );
  }
}
