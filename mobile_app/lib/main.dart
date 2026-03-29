import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/app_models.dart';
import 'models/campus_data.dart';
import 'models/faculty_models.dart';
import 'screens/badges_screen.dart';
import 'screens/campus_hub_screen.dart';
import 'screens/faculty_home_screen.dart';
import 'screens/faculty_volunteer_screen.dart';
import 'screens/farm_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/office_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/volunteer_screen.dart';
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
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.trim().isEmpty) {
      setState(() {
        _authError = 'Enter both email and password.';
        _authMessage = null;
      });
      return;
    }

    if (!isValidSchoolEmail(trimmedEmail)) {
      setState(() {
        _authError = 'Use a valid school email address ending in .edu.';
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
        email: trimmedEmail,
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
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required AppAccountType accountType,
    String? facultyPosition,
  }) async {
    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();
    final trimmedFacultyPosition = facultyPosition?.trim() ?? '';

    if (trimmedName.isEmpty ||
        trimmedEmail.isEmpty ||
        password.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      setState(() {
        _authError = 'Fill in every field to create your account.';
        _authMessage = null;
      });
      return;
    }

    final isFaculty = accountType == AppAccountType.faculty;
    if (isFaculty && trimmedFacultyPosition.isEmpty) {
      setState(() {
        _authError = 'Faculty accounts need a position or department for verification.';
        _authMessage = null;
      });
      return;
    }

    if (!isValidSchoolEmail(trimmedEmail)) {
      setState(() {
        _authError = 'Use a valid school email address ending in .edu.';
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

    final facultyVerified = !isFaculty ||
        _verifyFacultyIdentity(
          fullName: trimmedName,
          facultyPosition: trimmedFacultyPosition,
        );
    if (isFaculty && !facultyVerified) {
      setState(() {
        _authError =
            'We could not verify that faculty profile against our school faculty list. Please use your full name and a more specific position.';
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
        email: trimmedEmail,
        password: password,
      );
      await credential.user?.updateDisplayName(
        AppAccount.encodeDisplayName(
          fullName: trimmedName,
          accountType: accountType,
          facultyPosition: trimmedFacultyPosition.isEmpty
              ? null
              : trimmedFacultyPosition,
          isFacultyVerified: facultyVerified,
        ),
      );
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
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      setState(() {
        _authError = 'Enter your email first so we can send the reset link.';
        _authMessage = null;
      });
      return;
    }

    if (!isValidSchoolEmail(trimmedEmail)) {
      setState(() {
        _authError = 'Use a valid school email address ending in .edu.';
        _authMessage = null;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmedEmail);
      setState(() {
        _authMessage = 'Password reset email sent to $trimmedEmail.';
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

  bool _verifyFacultyIdentity({
    required String fullName,
    required String facultyPosition,
  }) {
    final normalizedName = fullName.toLowerCase();
    final normalizedPosition = facultyPosition.toLowerCase();
    final knownFacultyNames = {
      ...courseSchedule.map((item) => item.instructor.toLowerCase()),
      ...speakerProfiles
          .where((profile) => profile.company.toLowerCase().contains('cal poly pomona'))
          .map((profile) => profile.name.toLowerCase()),
    };

    final nameMatches = knownFacultyNames.any(
      (facultyName) =>
          normalizedName.contains(facultyName) ||
          facultyName.contains(normalizedName),
    );
    final roleLooksValid = normalizedPosition.contains('professor') ||
        normalizedPosition.contains('faculty') ||
        normalizedPosition.contains('instructor') ||
        normalizedPosition.contains('research') ||
        normalizedPosition.contains('director') ||
        normalizedPosition.contains('lecturer') ||
        normalizedPosition.contains('chair');

    return nameMatches || roleLooksValid;
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
          outline: softGold,
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
          indicatorColor: const Color(0xFFF3E8C8),
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
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required AppAccountType accountType,
    String? facultyPosition,
  }) onCreateAccount;
  final Future<void> Function(String email) onForgotPassword;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _facultyPositionController = TextEditingController();
  AppAccountType _accountType = AppAccountType.student;
  bool _createMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _facultyPositionController.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    if (_createMode) {
      return widget.onCreateAccount(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
        accountType: _accountType,
        facultyPosition: _accountType == AppAccountType.faculty
            ? _facultyPositionController.text
            : null,
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _createMode
                  ? 'Choose a student or faculty account. Student members keep the current engagement experience, while faculty unlock volunteer sourcing and office progression.'
                  : 'Track events, XP, avatar progress, and city unlocks.',
            ),
            const SizedBox(height: 20),
            if (_createMode) ...[
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<AppAccountType>(
                segments: const [
                  ButtonSegment<AppAccountType>(
                    value: AppAccountType.student,
                    label: Text('Student'),
                    icon: Icon(Icons.school_outlined),
                  ),
                  ButtonSegment<AppAccountType>(
                    value: AppAccountType.faculty,
                    label: Text('Faculty'),
                    icon: Icon(Icons.badge_outlined),
                  ),
                ],
                selected: {_accountType},
                onSelectionChanged: (selection) {
                  setState(() {
                    _accountType = selection.first;
                  });
                },
              ),
              if (_accountType == AppAccountType.faculty) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _facultyPositionController,
                  decoration: const InputDecoration(
                    labelText: 'Faculty position / department',
                    hintText: 'Assistant Professor of Marketing',
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
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
              child: _createMode
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          TextSpan(
                            text: 'Sign in',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: brandAccentDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    )
                  : Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Need an account? ',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          TextSpan(
                            text: 'Create one',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: brandAccentDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (!_createMode)
              TextButton(
                onPressed: widget.isSubmitting
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => ForgotPasswordScreen(
                              initialEmail: _emailController.text,
                              onSendReset: widget.onForgotPassword,
                            ),
                          ),
                        );
                      },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: warmTaupe,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum BasicTab { home, farm, volunteer, badges, hub }

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
  final List<FacultyOpportunity> _facultyOpportunities = buildFacultyOpportunities();
  final List<FacultyVolunteerRequest> _facultyRequests = <FacultyVolunteerRequest>[];
  String? _facultyResumeName;

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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: appBackground,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: QrScreen(onScanPressed: _showScannerDemo),
        ),
      ),
    );
  }

  void _showScannerDemo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Scanner'),
        content: const Text(
          'This demo opens QR check-in from the top-right action and keeps numeric code entry available too.',
        ),
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

  void _openVolunteer() {
    setState(() {
      _selectedTab = BasicTab.volunteer;
    });
  }

  void _uploadFacultyResume(String resumeName) {
    setState(() {
      _facultyResumeName = resumeName;
    });
  }

  void _submitFacultyRequest(FacultyOpportunity opportunity) {
    final alreadyRequested = _facultyRequests.any(
      (request) => request.opportunityId == opportunity.id,
    );
    if (alreadyRequested) return;
    setState(() {
      _facultyRequests.add(
        FacultyVolunteerRequest(
          opportunityId: opportunity.id,
          status: VolunteerRequestStatus.sent,
          resumeName: _facultyResumeName ?? 'resume.pdf',
          roleRequested: recommendedRoleForOpportunity(opportunity, _account),
        ),
      );
    });
  }

  void _advanceFacultyRequestStatus(FacultyVolunteerRequest request) {
    final index = _facultyRequests.indexOf(request);
    if (index == -1) return;
    setState(() {
      final nextStatus = switch (request.status) {
        VolunteerRequestStatus.sent => VolunteerRequestStatus.inReview,
        VolunteerRequestStatus.inReview => VolunteerRequestStatus.approved,
        VolunteerRequestStatus.approved => VolunteerRequestStatus.approved,
      };
      _facultyRequests[index] = FacultyVolunteerRequest(
        opportunityId: request.opportunityId,
        status: nextStatus,
        resumeName: request.resumeName,
        roleRequested: request.roleRequested,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFaculty = _account.isFaculty;
    final screen = switch (_selectedTab) {
      BasicTab.home => isFaculty
          ? FacultyHomeScreen(
              account: _account,
              state: widget.state,
              opportunities: _facultyOpportunities,
              requests: _facultyRequests,
              onOpenOffice: _openFarm,
              onOpenVolunteer: _openVolunteer,
              onOpenProfile: _openProfile,
            )
          : HomeScreen(
              account: _account,
              state: widget.state,
              onCheckIn: _showCheckInDialog,
              onOpenFarm: _openFarm,
              onOpenProfile: _openProfile,
            ),
      BasicTab.farm => isFaculty
          ? OfficeScreen(state: widget.state)
          : FarmScreen(state: widget.state),
      BasicTab.volunteer => isFaculty
          ? FacultyVolunteerScreen(
              account: _account,
              opportunities: _facultyOpportunities,
              requests: _facultyRequests,
              resumeName: _facultyResumeName,
              onResumeUploaded: _uploadFacultyResume,
              onSubmitRequest: _submitFacultyRequest,
              onAdvanceStatus: _advanceFacultyRequestStatus,
            )
          : VolunteerScreen(account: _account),
      BasicTab.badges => BadgesScreen(
          state: widget.state,
          account: _account,
          facultyRequests: _facultyRequests,
        ),
      BasicTab.hub => const CampusHubScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
        actions: isFaculty
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _showCheckInDialog,
                      child: Ink(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: appSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: softGold),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.qr_code_2_rounded,
                              size: 18,
                              color: brandAccentDark,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Check In',
                              style: TextStyle(
                                color: brandAccentDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
      ),
      body: SafeArea(top: false, child: screen),
      bottomNavigationBar: NavigationBar(
        selectedIndex: BasicTab.values.indexOf(_selectedTab),
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = BasicTab.values[index];
          });
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(isFaculty ? Icons.apartment_outlined : Icons.agriculture_outlined),
              label: isFaculty ? 'Office' : 'Farm'),
          const NavigationDestination(
              icon: Icon(Icons.volunteer_activism_outlined), label: 'Volunteer'),
          const NavigationDestination(
              icon: Icon(Icons.workspace_premium_outlined), label: 'Badges'),
          const NavigationDestination(
              icon: Icon(Icons.calendar_view_month_outlined), label: 'Hub'),
        ],
      ),
    );
  }
}
