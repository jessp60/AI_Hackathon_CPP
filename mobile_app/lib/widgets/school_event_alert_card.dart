import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme_constants.dart';

class SchoolEventAlertCard extends StatelessWidget {
  const SchoolEventAlertCard({
    super.key,
    required this.alert,
    required this.onDismiss,
    required this.onRemind,
    required this.onRegister,
    this.remindersEnabled = false,
    this.registrationOpened = false,
  });

  final SchoolEventAlert alert;
  final VoidCallback onDismiss;
  final VoidCallback onRemind;
  final VoidCallback onRegister;
  final bool remindersEnabled;
  final bool registrationOpened;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: softGold.withValues(alpha: 0.9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: softBlush,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: brandAccentDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New event for your school',
                      style: textTheme.titleSmall?.copyWith(
                        color: brandAccentDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.summary,
            style: textTheme.bodyMedium?.copyWith(
              color: appTextMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(
                icon: Icons.calendar_today_outlined,
                label: alert.eventDate,
              ),
              _MetaPill(
                icon: Icons.public_outlined,
                label: alert.sourceSite,
              ),
              if (remindersEnabled)
                const _MetaPill(
                  icon: Icons.alarm_on_outlined,
                  label: 'Reminders on',
                ),
              if (registrationOpened)
                const _MetaPill(
                  icon: Icons.open_in_new_rounded,
                  label: 'Event page opened',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: onDismiss,
                child: const Text('Dismiss'),
              ),
              OutlinedButton(
                onPressed: onRemind,
                style: OutlinedButton.styleFrom(
                  backgroundColor: remindersEnabled
                      ? softGold.withValues(alpha: 0.18)
                      : null,
                ),
                child: Text(remindersEnabled ? 'Reminders on' : 'Remind me'),
              ),
              FilledButton(
                onPressed: onRegister,
                child: Text(
                  registrationOpened ? 'Open again' : 'Learn more',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Sourced from approved public school pages with attribution and light review before surfacing.',
            style: textTheme.bodySmall?.copyWith(
              color: appTextMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: softBlush,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: brandAccentDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: brandAccentDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
