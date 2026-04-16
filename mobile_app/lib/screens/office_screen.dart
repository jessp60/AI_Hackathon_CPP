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
                      child: _OfficeAvatarBadge(
                        stage: state.officeStageNumber,
                        active: true,
                        size: 86,
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
                    stage: index + 1,
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
    required this.stage,
    required this.active,
    required this.unlocked,
    required this.xpLabel,
  });

  final String label;
  final int stage;
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
          _OfficeAvatarBadge(
            stage: stage,
            active: active,
            size: 44,
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

class _OfficeAvatarBadge extends StatelessWidget {
  const _OfficeAvatarBadge({
    required this.stage,
    required this.active,
    required this.size,
  });

  final int stage;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForStage(stage, active);
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.base, palette.highlight],
        ),
        border: Border.all(
          color: active ? Colors.white.withValues(alpha: 0.5) : mutedSurface,
          width: active ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.base.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.18,
            child: Icon(
              Icons.circle,
              size: size * 0.26,
              color: palette.foreground,
            ),
          ),
          Positioned(
            bottom: size * 0.16,
            child: Icon(
              Icons.person_rounded,
              size: size * 0.5,
              color: palette.foreground,
            ),
          ),
          Positioned(
            right: size * 0.1,
            bottom: size * 0.08,
            child: Container(
              height: size * 0.34,
              width: size * 0.34,
              decoration: BoxDecoration(
                color: active ? Colors.white : appSurface,
                shape: BoxShape.circle,
                border: Border.all(color: palette.highlight, width: 1.5),
              ),
              child: Icon(
                _accentIconForStage(stage),
                size: size * 0.18,
                color: palette.base,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPalette {
  const _AvatarPalette({
    required this.base,
    required this.highlight,
    required this.foreground,
  });

  final Color base;
  final Color highlight;
  final Color foreground;
}

_AvatarPalette _paletteForStage(int stage, bool active) {
  final foreground = active ? Colors.white : brandAccentDark;
  return switch (stage) {
    1 => _AvatarPalette(
        base: active ? const Color(0xFF355C7D) : const Color(0xFFDCE7F3),
        highlight: active ? softGold : const Color(0xFFF5E6BF),
        foreground: foreground,
      ),
    2 => _AvatarPalette(
        base: active ? const Color(0xFF2D6A4F) : const Color(0xFFDDF1E7),
        highlight: active ? softGold : const Color(0xFFF7E8C6),
        foreground: foreground,
      ),
    3 => _AvatarPalette(
        base: active ? const Color(0xFF6D597A) : const Color(0xFFE8DFF0),
        highlight: active ? softGold : const Color(0xFFF4E1C1),
        foreground: foreground,
      ),
    4 => _AvatarPalette(
        base: active ? const Color(0xFF7A4E2D) : const Color(0xFFF0E2D7),
        highlight: active ? softGold : const Color(0xFFF6E2BE),
        foreground: foreground,
      ),
    _ => _AvatarPalette(
        base: active ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        highlight: active ? softGold : const Color(0xFFF3E2BA),
        foreground: foreground,
      ),
  };
}

IconData _accentIconForStage(int stage) {
  return switch (stage) {
    1 => Icons.menu_book_rounded,
    2 => Icons.event_rounded,
    3 => Icons.handshake_rounded,
    4 => Icons.work_rounded,
    _ => Icons.apartment_rounded,
  };
}
