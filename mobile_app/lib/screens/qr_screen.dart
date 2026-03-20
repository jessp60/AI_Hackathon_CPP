import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({
    super.key,
    required this.onScanPressed,
  });

  final VoidCallback onScanPressed;

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your event code first.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checked in with code $code.')),
    );
    _codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  kIsWeb ? 'Event Code Check-In' : 'Check In',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  kIsWeb
                      ? 'Enter the event\'s alphanumeric code to record attendance on the web app.'
                      : 'Open the camera on mobile, or type the event\'s alphanumeric code instead.',
                  textAlign: TextAlign.center,
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: 20),
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 92,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: widget.onScanPressed,
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Open scanner'),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9-]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Event code',
                    hintText: 'EX: CPP-2026-A1',
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitCode,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Verify code'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
