import 'dart:math';

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../models/campus_data.dart';
import '../theme_constants.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({
    super.key,
    required this.account,
  });

  final AppAccount account;

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  final Set<int> _registeredEventIndexes = <int>{};
  final Set<int> _volunteeredIndexes = <int>{};
  _VolunteerFeedView _selectedFeed = _VolunteerFeedView.forYou;

  @override
  Widget build(BuildContext context) {
    final opportunities = List.generate(
      calendarEvents.length,
      (index) => _VolunteerOpportunity(
        eventIndex: index,
        calendarEvent: calendarEvents[index],
        contact: campusContacts[index % campusContacts.length],
        isRegistered: _registeredEventIndexes.contains(index),
        isVolunteering: _volunteeredIndexes.contains(index),
      ),
    );

    final recommendedOpportunities =
        _rankVolunteerOpportunities(widget.account, opportunities);
    final visibleOpportunities = _selectedFeed == _VolunteerFeedView.forYou
        ? recommendedOpportunities
        : opportunities;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'Volunteer',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Register for an event first, then unlock volunteer signup for that same event.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: appTextMuted,
                height: 1.35,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(24),
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
                'Future Event Calendar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: opportunities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 118,
                ),
                itemBuilder: (context, index) {
                  final opportunity = opportunities[index];
                  final parts = opportunity.calendarEvent.date.split('-');
                  final month = _monthLabel(parts[1]);
                  final day = parts[2];

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: opportunity.isRegistered
                          ? softBlush
                          : const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: opportunity.isVolunteering
                            ? brandAccent
                            : opportunity.isRegistered
                                ? softGold
                                : mutedSurface,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          month,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: appTextMuted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                        ),
                        Text(
                          day,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Spacer(),
                        Text(
                          opportunity.contact.program,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    height: 1.15,
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _VolunteerSummaryCard(
                label: 'Registered',
                value: '${_registeredEventIndexes.length}',
                icon: Icons.assignment_turned_in_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _VolunteerSummaryCard(
                label: 'Volunteer Signups',
                value: '${_volunteeredIndexes.length}',
                icon: Icons.volunteer_activism_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Volunteer Feed',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeedToggle(
                label: 'For You',
                selected: _selectedFeed == _VolunteerFeedView.forYou,
                onTap: () {
                  setState(() {
                    _selectedFeed = _VolunteerFeedView.forYou;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FeedToggle(
                label: 'All Events',
                selected: _selectedFeed == _VolunteerFeedView.all,
                onTap: () {
                  setState(() {
                    _selectedFeed = _VolunteerFeedView.all;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_selectedFeed == _VolunteerFeedView.forYou)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Ranked with cosine similarity using your member label and event keywords.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: appTextMuted,
                  ),
            ),
          ),
        ...visibleOpportunities.map(
          (opportunity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _VolunteerCard(
              opportunity: opportunity,
              onRegister: () => _registerForEvent(opportunity.eventIndex),
              onToggleVolunteer: opportunity.isRegistered
                  ? () => _toggleVolunteer(opportunity.eventIndex)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleVolunteer(int index) {
    final event = calendarEvents[index];
    final alreadyVolunteering = _volunteeredIndexes.contains(index);

    setState(() {
      if (alreadyVolunteering) {
        _volunteeredIndexes.remove(index);
      } else {
        _volunteeredIndexes.add(index);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyVolunteering
              ? 'Volunteer signup removed for ${event.region}.'
              : 'You signed up to volunteer at ${event.region}.',
        ),
      ),
    );
  }

  void _registerForEvent(int index) {
    final event = calendarEvents[index];
    final alreadyRegistered = _registeredEventIndexes.contains(index);

    setState(() {
      if (alreadyRegistered) {
        _registeredEventIndexes.remove(index);
        _volunteeredIndexes.remove(index);
      } else {
        _registeredEventIndexes.add(index);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyRegistered
              ? 'Registration removed for ${event.region}.'
              : 'You registered for ${event.region}. You can volunteer now.',
        ),
      ),
    );
  }
}

class _VolunteerSummaryCard extends StatelessWidget {
  const _VolunteerSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: brandAccentDark),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _FeedToggle extends StatelessWidget {
  const _FeedToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? brandAccentDark : appSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? brandAccentDark : mutedSurface,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : appTextMuted,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  const _VolunteerCard({
    required this.opportunity,
    required this.onRegister,
    required this.onToggleVolunteer,
  });

  final _VolunteerOpportunity opportunity;
  final VoidCallback onRegister;
  final VoidCallback? onToggleVolunteer;

  @override
  Widget build(BuildContext context) {
    final responsibility = _roleSummary(opportunity.contact.volunteerRoles);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(22),
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
            '${opportunity.calendarEvent.region} • ${opportunity.calendarEvent.date}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            opportunity.contact.program,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appTextMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            responsibility,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appText,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Volunteer roles: ${opportunity.contact.volunteerRoles}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                opportunity.isRegistered
                    ? 'Registered for this event'
                    : 'Register first to volunteer',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: opportunity.isRegistered
                          ? brandAccentDark
                          : appTextMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              OutlinedButton(
                onPressed: onRegister,
                child: Text(
                  opportunity.isRegistered ? 'Registered' : 'Register',
                ),
              ),
              FilledButton(
                onPressed: onToggleVolunteer,
                child: Text(
                  opportunity.isVolunteering ? 'Signed Up' : 'Volunteer',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VolunteerOpportunity {
  const _VolunteerOpportunity({
    required this.eventIndex,
    required this.calendarEvent,
    required this.contact,
    required this.isRegistered,
    required this.isVolunteering,
  });

  final int eventIndex;
  final CalendarEvent calendarEvent;
  final CampusContact contact;
  final bool isRegistered;
  final bool isVolunteering;
}

enum _VolunteerFeedView { forYou, all }

String _monthLabel(String month) {
  return switch (month) {
    '01' => 'Jan',
    '02' => 'Feb',
    '03' => 'Mar',
    '04' => 'Apr',
    '05' => 'May',
    '06' => 'Jun',
    '07' => 'Jul',
    '08' => 'Aug',
    '09' => 'Sep',
    '10' => 'Oct',
    '11' => 'Nov',
    _ => 'Dec',
  };
}

String _roleSummary(String roles) {
  final normalizedRoles = roles
      .split(';')
      .map((role) => role.trim())
      .where((role) => role.isNotEmpty)
      .toList();
  if (normalizedRoles.isEmpty) {
    return 'Support attendees with light event help and student-facing logistics.';
  }
  final leadRole = normalizedRoles.first.toLowerCase();
  return 'Help with the event by serving as a $leadRole, supporting attendees, and staying available during the main activity window.';
}

List<_VolunteerOpportunity> _rankVolunteerOpportunities(
  AppAccount account,
  List<_VolunteerOpportunity> opportunities,
) {
  final userVector = _tokenVector(
    '${account.memberLabel} ${account.fullName} ${account.email}',
  );

  final scored = opportunities
      .map(
        (opportunity) => (
          opportunity: opportunity,
          score: _cosineSimilarity(
            userVector,
            _tokenVector(
              '${opportunity.calendarEvent.region} '
              '${opportunity.calendarEvent.courseAlignment} '
              '${opportunity.contact.category} '
              '${opportunity.contact.volunteerRoles} '
              '${opportunity.contact.audience}',
            ),
          ),
        ),
      )
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  return scored.map((item) => item.opportunity).toList();
}

Map<String, double> _tokenVector(String input) {
  final matches = RegExp(r'[a-zA-Z0-9]+')
      .allMatches(input.toLowerCase())
      .map((match) => match.group(0)!);
  final vector = <String, double>{};
  for (final token in matches) {
    vector[token] = (vector[token] ?? 0) + 1;
  }
  return vector;
}

double _cosineSimilarity(
  Map<String, double> left,
  Map<String, double> right,
) {
  if (left.isEmpty || right.isEmpty) return 0;

  var dot = 0.0;
  var leftMagnitude = 0.0;
  var rightMagnitude = 0.0;

  for (final entry in left.entries) {
    leftMagnitude += entry.value * entry.value;
    dot += entry.value * (right[entry.key] ?? 0);
  }

  for (final value in right.values) {
    rightMagnitude += value * value;
  }

  if (leftMagnitude == 0 || rightMagnitude == 0) return 0;
  return dot / (sqrt(leftMagnitude) * sqrt(rightMagnitude));
}
