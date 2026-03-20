import 'package:flutter/material.dart';

import '../models/app_models.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key, required this.state});

  final SimpleState state;

  @override
  Widget build(BuildContext context) {
    final badges = <_BadgeItem>[
      _BadgeItem(
        title: 'XP Explorer',
        description: 'Earned for reaching level ${state.level}.',
        icon: Icons.workspace_premium_outlined,
        unlocked: true,
      ),
      _BadgeItem(
        title: 'City Scout',
        description:
            'Unlocked ${state.cities.where((city) => city.unlocked).length} travel spots.',
        icon: Icons.map_outlined,
        unlocked: state.cities.any((city) => city.unlocked),
      ),
      _BadgeItem(
        title: 'Event Regular',
        description: 'Keep attending events to stack more badges.',
        icon: Icons.emoji_events_outlined,
        unlocked: state.totalXp >= 1000,
      ),
      const _BadgeItem(
        title: 'Bronco Builder',
        description: 'Reach your next avatar stage to unlock this badge.',
        icon: Icons.construction_outlined,
        unlocked: false,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: badges.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(badge.icon),
            ),
            title: Text(badge.title),
            subtitle: Text(badge.description),
            trailing: Text(badge.unlocked ? 'Unlocked' : 'Locked'),
          ),
        );
      },
    );
  }
}

class _BadgeItem {
  const _BadgeItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
}
