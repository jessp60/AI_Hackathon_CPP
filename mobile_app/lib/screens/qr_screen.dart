import 'package:flutter/material.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({
    super.key,
    required this.onScanPressed,
  });

  final VoidCallback onScanPressed;

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
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 92,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'QR Check-In',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scan an event QR code to check in and earn XP for your account.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onScanPressed,
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Open scanner'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
