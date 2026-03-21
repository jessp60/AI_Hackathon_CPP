import 'package:flutter/material.dart';

import '../theme_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.initialEmail,
    required this.onSendReset,
  });

  final String initialEmail;
  final Future<void> Function(String email) onSendReset;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final trimmedEmail = _emailController.text.trim();

    if (trimmedEmail.isEmpty) {
      setState(() {
        _errorMessage = 'Enter your school email to continue.';
        _infoMessage = null;
      });
      return;
    }

    if (!isValidSchoolEmail(trimmedEmail)) {
      setState(() {
        _errorMessage = 'Use a valid school email address ending in .edu.';
        _infoMessage = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      await widget.onSendReset(trimmedEmail);
      if (!mounted) return;
      setState(() {
        _infoMessage = 'Reset instructions were sent to $trimmedEmail.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to send the reset email right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
              'Forgot password',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your school email and we will send a password reset email so you can continue.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'School email'),
              onChanged: (_) {
                if (_errorMessage != null || _infoMessage != null) {
                  setState(() {
                    _errorMessage = null;
                    _infoMessage = null;
                  });
                }
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_infoMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _infoMessage!,
                style: const TextStyle(color: brandAccent),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(
                  _isSubmitting ? 'Sending...' : 'Send reset email',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isValidSchoolEmail(String email) {
  final normalizedEmail = email.trim().toLowerCase();
  return RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.edu$')
      .hasMatch(normalizedEmail);
}
