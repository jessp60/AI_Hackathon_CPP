import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../widgets/profile_avatar.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({
    super.key,
    required this.account,
    required this.state,
  });

  final AppAccount account;
  final SimpleState state;

  @override
  Widget build(BuildContext context) {
    final entries = [
      _LeaderboardEntry(
        name: 'Avery Chen',
        subtitle: 'Campus Innovator',
        xp: state.totalXp + 240,
        rank: 1,
      ),
      _LeaderboardEntry(
        name: 'Jordan Patel',
        subtitle: 'Hackathon Veteran',
        xp: state.totalXp + 120,
        rank: 2,
      ),
      _LeaderboardEntry(
        name: account.fullName,
        subtitle: 'You',
        xp: state.totalXp,
        rank: state.rank,
        isCurrentUser: true,
      ),
      _LeaderboardEntry(
        name: 'Mia Thompson',
        subtitle: 'Networking Pro',
        xp: state.totalXp - 85,
        rank: state.rank + 1,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentUser = entry.isCurrentUser;
        return Card(
          child: ListTile(
            leading: isCurrentUser
                ? ProfileAvatar(account: account)
                : CircleAvatar(child: Text('#${entry.rank}')),
            title: Text(entry.name),
            subtitle: Text(entry.subtitle),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.xp} XP',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('Rank ${entry.rank}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.name,
    required this.subtitle,
    required this.xp,
    required this.rank,
    this.isCurrentUser = false,
  });

  final String name;
  final String subtitle;
  final int xp;
  final int rank;
  final bool isCurrentUser;
}
