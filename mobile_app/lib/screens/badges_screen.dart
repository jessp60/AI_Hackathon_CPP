import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../models/faculty_models.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({
    super.key,
    required this.state,
    required this.account,
    this.facultyRequests = const [],
  });

  final SimpleState state;
  final AppAccount account;
  final List<FacultyVolunteerRequest> facultyRequests;

  @override
  Widget build(BuildContext context) {
    final badges = account.isFaculty
        ? _facultyBadges()
        : _studentBadges();

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

  List<_BadgeItem> _studentBadges() {
    return <_BadgeItem>[
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
  }

  List<_BadgeItem> _facultyBadges() {
    final approvedCount = facultyRequests
        .where((request) => request.status == VolunteerRequestStatus.approved)
        .length;
    final reviewCount = facultyRequests
        .where((request) => request.status == VolunteerRequestStatus.inReview)
        .length;
    final requestedRoles =
        facultyRequests.map((request) => request.roleRequested.toLowerCase()).join(' ');

    return <_BadgeItem>[
      _BadgeItem(
        title: 'First Request',
        description: 'Send your first volunteer request to a campus event.',
        icon: Icons.send_outlined,
        unlocked: facultyRequests.isNotEmpty,
      ),
      _BadgeItem(
        title: 'Judge on Deck',
        description: 'Volunteer for a judging role at a competition or hackathon.',
        icon: Icons.gavel_outlined,
        unlocked: requestedRoles.contains('judge'),
      ),
      _BadgeItem(
        title: 'Career Panelist',
        description: 'Support a career fair or employer event as a panelist.',
        icon: Icons.groups_outlined,
        unlocked: requestedRoles.contains('panelist'),
      ),
      _BadgeItem(
        title: 'Research Voice',
        description: 'Speak at a research symposium or academic showcase.',
        icon: Icons.mic_none_outlined,
        unlocked: requestedRoles.contains('speaker'),
      ),
      _BadgeItem(
        title: 'Mentor Matchmaker',
        description: 'Guide students through mentor-style volunteering.',
        icon: Icons.handshake_outlined,
        unlocked: requestedRoles.contains('mentor'),
      ),
      _BadgeItem(
        title: 'In Review',
        description: 'Have at least one volunteer request under review.',
        icon: Icons.pending_actions_outlined,
        unlocked: reviewCount > 0,
      ),
      _BadgeItem(
        title: 'Confirmed Volunteer',
        description: 'Get approved for at least one university opportunity.',
        icon: Icons.verified_outlined,
        unlocked: approvedCount > 0,
      ),
      _BadgeItem(
        title: 'Board Builder',
        description: 'Reach the Young Professional office stage.',
        icon: Icons.business_center_outlined,
        unlocked: state.officeStageNumber >= 4,
      ),
    ];
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
