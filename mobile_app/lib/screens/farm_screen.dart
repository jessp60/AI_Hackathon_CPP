import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme_constants.dart';

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key, required this.state});

  final SimpleState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = state.levelProgress.clamp(0.0, 1.0);
    final stages = [
      const _EvolutionStage(
          label: 'Foal',
          xp: '0 XP',
          useDotIcon: true,
          unlocked: true),
      const _EvolutionStage(
          label: 'Pony',
          xp: '500 XP',
          useDotIcon: true,
          unlocked: true),
      const _EvolutionStage(
        label: 'Young\nHorse',
        xp: '1500 XP',
        useDotIcon: true,
        unlocked: true,
        active: true,
      ),
      const _EvolutionStage(
          label: 'Adult\nHorse', xp: '3000 XP', stepNumber: 4),
      const _EvolutionStage(label: 'Champion', xp: '5000 XP', stepNumber: 5),
    ];
    final cosmetics = [
      const _CosmeticItem(
        icon: Icons.apps_rounded,
        name: 'Golden\nSaddle',
        type: 'Saddle',
        footer: 'Owned',
        owned: true,
      ),
      const _CosmeticItem(
        icon: Icons.apps_rounded,
        name: 'Racing\nStripes',
        type: 'Pattern',
        footer: 'Owned',
        owned: true,
      ),
      const _CosmeticItem(
        icon: Icons.apps_rounded,
        name: 'Champion\nCrown',
        type: 'Accessory',
        footer: '5000',
      ),
      const _CosmeticItem(
        icon: Icons.apps_rounded,
        name: 'Rainbow\nMane',
        type: 'Color',
        footer: '4000',
      ),
      const _CosmeticItem(
        icon: Icons.apps_rounded,
        name: 'Diamond\nShoes',
        type: 'Shoes',
        footer: '6000',
      ),
      const _CosmeticItem(
        icon: Icons.apps_rounded,
        name: 'Wings',
        type: 'Special',
        footer: '10000',
      ),
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Top hero field with horse summary chips and the exploring callout.
        SizedBox(
          height: 800,
          child: Stack(
            children: [
              Container(
                height: 720,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB8D7BF), Color(0xFF8CB28A), Color(0xFF6A8B5A)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 210,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x99FFFFFF), Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      right: -20,
                      bottom: 180,
                      child: Container(
                        height: 180,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x661D5138), Color(0x001D5138)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 28,
                      right: 28,
                      top: 24,
                      child: Row(
                        children: [
                          Expanded(
                            child: _TopInfoCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thunder',
                                    style: textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lv. ${state.level - 1} • Young Horse',
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: appTextMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          _TopInfoCard(
                            width: 180,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'XP',
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: appTextMuted,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${state.totalXp}/${state.totalXp + state.xpToNextStage}',
                                  style: textTheme.displaySmall?.copyWith(
                                    color: brandAccentDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 96,
                      bottom: 250,
                      child: Text(
                        '🐎',
                        style: textTheme.displayMedium?.copyWith(fontSize: 54),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 112,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: appSurface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFD9E0D8), width: 4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: brandAccentDark,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Your horse is exploring\nthe farm!',
                                style: textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF37465D),
                                  height: 1.2,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          18,
                          (index) => Container(
                            width: 12,
                            height: 42 + (index % 3) * 8,
                            decoration: BoxDecoration(
                              color: const Color(0x33428745),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 0,
                child: _PanelCard(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Evolution Progress',
                                  style: textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Keep earning XP to evolve!',
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: appTextMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Next Evolution: Adult\nHorse',
                              style: textTheme.headlineSmall?.copyWith(
                                color: appTextMuted,
                                height: 1.25,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '${state.totalXp} / ${state.totalXp + state.xpToNextStage}\nXP',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 18,
                          backgroundColor: const Color(0xFFE1E3EA),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(brandAccent),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: stages
                            .map((stage) => Expanded(child: _StagePill(stage: stage)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Icon(
                Icons.palette_outlined,
                color: brandAccentDark,
                size: 34,
              ),
              const SizedBox(width: 12),
              Text(
                'Cosmetics & Upgrades',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            itemCount: cosmetics.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 228,
            ),
            itemBuilder: (context, index) {
              return _CosmeticCard(item: cosmetics[index]);
            },
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFECEEE8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE3D4BC)),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Evolution Tip: ',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Your horse evolves at levels 1, 2, 3, 4, and 5! Each evolution makes it stronger and unlocks new cosmetics.',
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF3E4A60),
                      height: 1.35,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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

class _EvolutionStage {
  const _EvolutionStage({
    required this.label,
    required this.xp,
    this.useDotIcon = false,
    this.stepNumber,
    this.unlocked = false,
    this.active = false,
  });

  final String label;
  final String xp;
  final bool useDotIcon;
  final int? stepNumber;
  final bool unlocked;
  final bool active;
}

class _StagePill extends StatelessWidget {
  const _StagePill({required this.stage});

  final _EvolutionStage stage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final circleColor = stage.active
        ? brandAccent
        : stage.unlocked
            ? softGold
            : Colors.white;
    final borderColor = stage.unlocked || stage.active
        ? Colors.transparent
        : const Color(0xFFD0D5DF);

    return Column(
      children: [
        Container(
          height: 94,
          width: 94,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
            border: Border.all(color: borderColor, width: 4),
          ),
          alignment: Alignment.center,
          child: stage.useDotIcon
              ? Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: stage.active
                        ? Colors.white
                        : stage.unlocked
                            ? appText
                            : const Color(0xFF8A92A2),
                    shape: BoxShape.circle,
                  ),
                )
              : Text(
                  '${stage.stepNumber}',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF8A92A2),
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stage.label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: stage.active
                    ? brandAccentDark
                    : stage.unlocked
                        ? softGold
                        : const Color(0xFF9098A8),
                fontWeight: FontWeight.w700,
                height: 1.2,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stage.xp,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: const Color(0xFF657084),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _CosmeticItem {
  const _CosmeticItem({
    required this.icon,
    required this.name,
    required this.type,
    required this.footer,
    this.owned = false,
  });

  final IconData icon;
  final String name;
  final String type;
  final String footer;
  final bool owned;
}

class _CosmeticCard extends StatelessWidget {
  const _CosmeticCard({required this.item});

  final _CosmeticItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: item.owned ? brandAccent : const Color(0xFFDDE0E8),
          width: item.owned ? 2.5 : 1.5,
        ),
        boxShadow: item.owned
            ? const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 34,
            color: item.owned ? appText : const Color(0xFF697387),
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: item.owned ? appText : const Color(0xFF697387),
                  fontSize: 13,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.type,
                style: textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF697387),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          item.owned
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: softBlush,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_outlined,
                          size: 14,
                          color: brandAccentDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.footer,
                          style: textTheme.titleMedium?.copyWith(
                            color: brandAccentDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_border_rounded,
                      color: Color(0xFF4E5A71),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.footer,
                      style: textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF4E5A71),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
