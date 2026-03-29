import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme_constants.dart';

class OfficeScreen extends StatelessWidget {
  const OfficeScreen({super.key, required this.state});

  final SimpleState state;

  @override
  Widget build(BuildContext context) {
    const stageNames = [
      'Student Member',
      'Local Event Attendee',
      'Mentee Match',
      'Young Professional',
      'Corporate Member',
    ];
    const stageIcons = [
      Icons.school_outlined,
      Icons.event_available_outlined,
      Icons.handshake_outlined,
      Icons.business_center_outlined,
      Icons.apartment_outlined,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [brandAccentDark, brandAccent, Color(0xFF395946)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leadership Office',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Progress through volunteer leadership milestones as you judge, mentor, speak, and support campus programs.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 86,
                      width: 86,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        size: 42,
                        color: brandAccentDark,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stage ${state.officeStageNumber}: ${state.officeStageTitle}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: state.officeProgress.clamp(0.0, 1.0),
                              minHeight: 14,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(softGold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${state.totalXp} / ${state.xpForNextOfficeStage} XP',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Office Growth Path',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                stageNames.length,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index == stageNames.length - 1 ? 0 : 12),
                  child: _OfficeStageTile(
                    label: stageNames[index],
                    icon: stageIcons[index],
                    active: state.officeStageNumber == index + 1,
                    unlocked: state.officeStageNumber > index + 1,
                    xpLabel: const ['0 XP', '500 XP', '1500 XP', '3000 XP', '5000 XP'][index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfficeStageTile extends StatelessWidget {
  const _OfficeStageTile({
    required this.label,
    required this.icon,
    required this.active,
    required this.unlocked,
    required this.xpLabel,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool unlocked;
  final String xpLabel;

  @override
  Widget build(BuildContext context) {
    final background = active
        ? brandAccentDark
        : unlocked
            ? softBlush
            : const Color(0xFFF6F7F8);

    final foreground = active ? Colors.white : brandAccentDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: active ? brandAccentDark : mutedSurface),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: active ? Colors.white.withValues(alpha: 0.18) : softGold,
            child: Icon(icon, color: foreground),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  xpLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: active ? Colors.white70 : appTextMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
