import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme_constants.dart';

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key, required this.state});

  final SimpleState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accessories = state.unlockedAccessories;
    final upcomingStageNames = [
      'Tiny Pony',
      'Pony',
      'Young Bronco',
      'Adult Bronco',
      'Champion Bronco',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFBEDFBD),
                Color(0xFF95BC78),
                Color(0xFF759C57),
              ],
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
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TopInfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thunder',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Lv. ${state.farmStageNumber} • ${state.farmStageTitle}',
                            style: textTheme.titleMedium?.copyWith(
                              color: appTextMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _TopInfoCard(
                    width: 148,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'XP',
                          style: textTheme.titleMedium?.copyWith(
                            color: appTextMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.totalXp}/${state.xpForNextFarmStage}',
                          style: textTheme.headlineMedium?.copyWith(
                            color: brandAccentDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 270,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x99FFFFFF), Color(0x3365A05A)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        children: [
                          const Spacer(),
                          Container(
                            height: 90,
                            decoration: const BoxDecoration(
                              color: Color(0x66407F43),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(28),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 20,
                      child: _FarmStatusPill(
                        icon: Icons.pets_outlined,
                        label: '${state.unlockedHorseCount} horses',
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: _FarmStatusPill(
                        icon: Icons.auto_awesome_outlined,
                        label: '${accessories.length} accessories',
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 72,
                      child: Column(
                        children: [
                          const _BroncoSprite(size: 88),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            alignment: WrapAlignment.center,
                            children: List.generate(
                              state.unlockedHorseCount - 1,
                              (index) => const Opacity(
                                opacity: 0.85,
                                child: _BroncoSprite(size: 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          12,
                          (index) => Container(
                            width: 9,
                            height: 30 + (index % 3) * 8,
                            decoration: BoxDecoration(
                              color: const Color(0x4D2D7332),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 30,
                      right: 30,
                      bottom: 22,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: appSurface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFD8E0D5),
                            width: 3,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: brandAccentDark,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                accessories.isEmpty
                                    ? 'Your tiny bronco is just getting started on the farm.'
                                    : 'Thunder is stronger now and showing off new gear.',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF37465D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _PanelCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Farm Evolution',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'As your points rise, Thunder grows into a stronger bronco, unlocks more gear, and brings more horses to the farm.',
                style: textTheme.bodyLarge?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Next Evolution: ${state.nextFarmStageTitle}',
                      style: textTheme.titleMedium?.copyWith(
                        color: appTextMuted,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Container(
                    height: 74,
                    width: 74,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [brandAccentDark, softGold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '${state.totalXp} / ${state.xpForNextFarmStage} XP',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: state.farmProgress.clamp(0.0, 1.0),
                  minHeight: 16,
                  backgroundColor: const Color(0xFFE1E3EA),
                  valueColor: const AlwaysStoppedAnimation<Color>(brandAccent),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  upcomingStageNames.length,
                  (index) => Expanded(
                    child: _StagePill(
                      label: upcomingStageNames[index],
                      xpLabel: const ['0 XP', '500 XP', '1500 XP', '3000 XP', '5000 XP'][index],
                      active: state.farmStageNumber == index + 1,
                      unlocked: state.farmStageNumber > index + 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _PanelCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlocked Accessories',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              if (accessories.isEmpty)
                Text(
                  'Earn your first 250 XP to unlock a bandana for Thunder.',
                  style: textTheme.bodyLarge?.copyWith(color: appTextMuted),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: accessories
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: softBlush,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: brandAccentDark,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _PanelCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Farm Friends',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.unlockedHorseCount == 1
                    ? 'Keep earning points to add more broncos to your farm.'
                    : 'Your higher point total has already attracted more broncos to the farm.',
                style: textTheme.bodyLarge?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(
                  state.unlockedHorseCount,
                  (index) => Container(
                    width: 96,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: softBlush,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        const _BroncoSprite(size: 42),
                        const SizedBox(height: 8),
                        Text(
                          index == 0 ? 'Thunder' : 'Bronco ${index + 1}',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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

class _TopInfoCard extends StatelessWidget {
  const _TopInfoCard({
    required this.child,
    this.width,
  });

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StagePill extends StatelessWidget {
  const _StagePill({
    required this.label,
    required this.xpLabel,
    required this.active,
    required this.unlocked,
  });

  final String label;
  final String xpLabel;
  final bool active;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final circleColor = active
        ? brandAccent
        : unlocked
            ? softGold
            : Colors.white;
    final borderColor = unlocked || active
        ? Colors.transparent
        : const Color(0xFFD0D5DF);

    return Column(
      children: [
        Container(
          height: 62,
          width: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
            border: Border.all(color: borderColor, width: 3),
          ),
          alignment: Alignment.center,
          child: Icon(
            active || unlocked ? Icons.pets : Icons.lock_outline,
            color: active
                ? Colors.white
                : unlocked
                    ? appText
                    : const Color(0xFF9DA4B4),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: active ? brandAccentDark : appTextMuted,
            fontWeight: active ? FontWeight.w800 : FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          xpLabel,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: active ? brandAccentDark : appTextMuted,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FarmStatusPill extends StatelessWidget {
  const _FarmStatusPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appSurface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: brandAccentDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: brandAccentDark,
                ),
          ),
        ],
      ),
    );
  }
}

class _BroncoSprite extends StatelessWidget {
  const _BroncoSprite({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Image.asset(
        '../Asset Pack/Sprites/bzdig ci.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.pets_rounded,
          size: size,
          color: brandAccentDark,
        ),
      ),
    );
  }
}
