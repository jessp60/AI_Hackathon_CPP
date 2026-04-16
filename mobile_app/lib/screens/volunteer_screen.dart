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
  _VolunteerFeedView _selectedFeed = _VolunteerFeedView.forYou;
  String? _selectedOpportunitySchool;

  @override
  Widget build(BuildContext context) {
    final scopedAccount = _scopedAccount();
    final opportunities = _buildOpportunities();
    final schoolOptions = availableSchoolNames();
    final registeredOpportunities = opportunities
        .where((opportunity) => opportunity.isRegistered)
        .toList(growable: false);
    final scoredRegistered = _scoreVolunteerMatches(
      scopedAccount,
      registeredOpportunities,
    );
    final scoredAll = _scoreVolunteerMatches(scopedAccount, opportunities);
    final hasRegisteredEvents = registeredOpportunities.isNotEmpty;
    final visibleMatches = _selectedFeed == _VolunteerFeedView.forYou
        ? (hasRegisteredEvents ? scoredRegistered : scoredAll)
        : scoredAll;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'Events',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        // Text(
        //   'Students register for events first, then unlock tailored volunteer recommendations based on topic fit, role fit, geography, timing, and interest signals.',
        //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        //         color: appTextMuted,
        //         height: 1.35,
        //       ),
        // ),
        // const SizedBox(height: 16),
        _buildCalendarCard(context, opportunities),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _VolunteerSummaryCard(
                label: 'Registered Events',
                value: '${_registeredEventIndexes.length}',
                icon: Icons.assignment_turned_in_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Event Registration',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Register here first. Your volunteer recommendations below update from the events you choose.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: appTextMuted,
              ),
        ),
        const SizedBox(height: 14),
        ...opportunities.map(
          (opportunity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RegistrationCard(
              opportunity: opportunity,
              onRegister: () => _registerForEvent(opportunity.eventIndex),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Recommended Events',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'The For You feed uses a weighted prototype score tuned for student event matching.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: appTextMuted,
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
        if (_selectedFeed == _VolunteerFeedView.forYou &&
            !hasRegisteredEvents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: softBlush,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: mutedSurface),
              ),
              child: Text(
                'No event registrations yet, so these matches are currently based on your selected interests and expertise. Once you register, the feed will blend in your event history too.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appTextMuted,
                      height: 1.35,
                    ),
              ),
            ),
          ),
        ...[
          if (_selectedFeed == _VolunteerFeedView.forYou)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                hasRegisteredEvents
                    ? 'For You ranks your registered events for ${scopedAccount.schoolName} with topic fit, role fit, geography, timing, past event history, and student interest signals.'
                    : 'For You is currently ranking ${scopedAccount.schoolName} opportunities from your interests, expertise, and past event history until you register for one.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appTextMuted,
                      height: 1.35,
                    ),
              ),
            ),
          ...visibleMatches.map(
            (match) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VolunteerMatchCard(
                match: match,
                onRegister: () => _registerForEvent(match.opportunity.eventIndex),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Container(
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
                'Explore opportunities at another school',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you are visiting or helping another campus, switch the school scope here and we will show opportunities for that campus or school system.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appTextMuted,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue:
                    _selectedOpportunitySchool ?? widget.account.schoolName,
                decoration: const InputDecoration(
                  labelText: 'Opportunity school',
                ),
                items: schoolOptions
                    .map(
                      (school) => DropdownMenuItem<String>(
                        value: school,
                        child: Text(school),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedOpportunitySchool = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_VolunteerOpportunity> _buildOpportunities() {
    final scopedAccount = _scopedAccount();
    final scopedContacts = campusContacts
        .where(
          (contact) => schoolMatchesOpportunity(
            scopedAccount,
            '${contact.program} ${contact.hostUnit} ${contact.publicUrl} ${contact.audience}',
          ),
        )
        .toList(growable: false);
    final fallbackContacts = scopedContacts.isEmpty
        ? _fallbackContactsForAccount(scopedAccount)
        : scopedContacts;
    final safeContacts = fallbackContacts.isEmpty
        ? [_genericFallbackContact(scopedAccount)]
        : fallbackContacts;
    final scopedEvents = calendarEvents
        .where(
          (event) => schoolMatchesOpportunity(
            scopedAccount,
            '${event.region} ${event.nearbyUniversities} ${event.courseAlignment}',
          ),
        )
        .toList(growable: false);
    final fallbackEvents = scopedEvents.isEmpty
        ? calendarEvents.take(4).toList(growable: false)
        : scopedEvents;

    final opportunities = List.generate(
      fallbackEvents.length,
      (index) => _VolunteerOpportunity(
        eventIndex: calendarEvents.indexOf(fallbackEvents[index]),
        calendarEvent: fallbackEvents[index],
        contact: safeContacts[index % safeContacts.length],
        isRegistered:
            _registeredEventIndexes.contains(calendarEvents.indexOf(fallbackEvents[index])),
        isVolunteering: false,
      ),
    );

    opportunities.sort(
      (left, right) => DateTime.parse(
        left.calendarEvent.date,
      ).compareTo(DateTime.parse(right.calendarEvent.date)),
    );
    return opportunities;
  }

  AppAccount _scopedAccount() {
    final selectedSchool = _selectedOpportunitySchool;
    if (selectedSchool == null || selectedSchool == widget.account.schoolName) {
      return widget.account;
    }
    return widget.account.copyWith(
      schoolName: selectedSchool,
      schoolOrganization: organizationForSchool(selectedSchool),
      selectedSchools: [selectedSchool],
    );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    List<_VolunteerOpportunity> opportunities,
  ) {
    return Container(
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
          const SizedBox(height: 8),
          Text(
            'Chronological event view for registration planning.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appTextMuted,
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
              mainAxisExtent: 124,
            ),
            itemBuilder: (context, index) {
              final opportunity = opportunities[index];
              final parts = opportunity.calendarEvent.date.split('-');
              final month = _monthLabel(parts[1]);
              final day = parts[2];

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      opportunity.isRegistered ? softBlush : const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: opportunity.isRegistered ? softGold : mutedSurface,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: appTextMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                    ),
                    Text(
                      day,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        opportunity.contact.program,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              height: 1.15,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _registerForEvent(int eventIndex) {
    final opportunity = calendarEvents[eventIndex];
    final alreadyRegistered = _registeredEventIndexes.contains(eventIndex);

    setState(() {
      if (alreadyRegistered) {
        _registeredEventIndexes.remove(eventIndex);
      } else {
        _registeredEventIndexes.add(eventIndex);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyRegistered
              ? 'Registration removed for ${opportunity.region}.'
              : 'You registered for ${opportunity.region}. Event matching is now updated.',
        ),
      ),
    );
  }
}

List<CampusContact> _fallbackContactsForAccount(AppAccount account) {
  return switch (account.schoolOrganization) {
    SchoolOrganization.uc => const [
        CampusContact(
          program: 'UC Networking and Mentorship Session',
          category: 'Career panel',
          recurrence: 'Recurring',
          hostUnit: 'University of California system',
          volunteerRoles: 'Mentor; Panelist; Guest speaker',
          audience: 'UC students',
          publicUrl: 'https://admission.universityofcalifornia.edu/',
          contactName: 'UC campus engagement teams',
          contactInfo: 'See campus event page',
        ),
        CampusContact(
          program: 'UC Research Symposium Connection Hour',
          category: 'Research symposium',
          recurrence: 'Annual',
          hostUnit: 'University of California system',
          volunteerRoles: 'Guest speaker; Reviewer',
          audience: 'UC researchers and students',
          publicUrl: 'https://admission.universityofcalifornia.edu/',
          contactName: 'UC research event teams',
          contactInfo: 'See campus event page',
        ),
      ],
    SchoolOrganization.privateSchool => [
        CampusContact(
          program: '${account.schoolName} Career Connections Night',
          category: 'Career panel',
          recurrence: 'Recurring',
          hostUnit: account.schoolName,
          volunteerRoles: 'Mentor; Panelist',
          audience: 'Students and alumni',
          publicUrl: 'https://www.aiccu.edu/',
          contactName: 'Campus event office',
          contactInfo: 'See campus event page',
        ),
      ],
    _ => const [],
  };
}

CampusContact _genericFallbackContact(AppAccount account) {
  return CampusContact(
    program: '${account.schoolName} Opportunity Board',
    category: 'Career and networking event',
    recurrence: 'Rolling',
    hostUnit: account.schoolName,
    volunteerRoles: 'Mentor; Guest speaker; Panelist',
    audience: 'Students, alumni, and campus partners',
    publicUrl: 'https://www.insightsassociation.org/Membership/Chapters/West',
    contactName: 'Campus opportunity coordinator',
    contactInfo: 'See the linked school or IA West page for current details.',
  );
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

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({
    required this.opportunity,
    required this.onRegister,
  });

  final _VolunteerOpportunity opportunity;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.contact.program,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${opportunity.calendarEvent.date} • ${opportunity.calendarEvent.region}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: appTextMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: softBlush,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  opportunity.contact.category,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: brandAccentDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Audience: ${opportunity.contact.audience}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Linked IA lecture window: ${opportunity.calendarEvent.lectureWindow}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onRegister,
              icon: Icon(
                opportunity.isRegistered
                    ? Icons.check_circle_outline
                    : Icons.app_registration_outlined,
              ),
              label: Text(
                opportunity.isRegistered ? 'Registered' : 'Register for Event',
              ),
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

class _EmptyVolunteerState extends StatelessWidget {
  const _EmptyVolunteerState({
    required this.account,
  });

  final AppAccount account;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
            'No registered events yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Register for an event above first, then we’ll rank the best volunteer matches for your ${account.memberLabel.toLowerCase()} profile.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerMatchCard extends StatelessWidget {
  const _VolunteerMatchCard({
    required this.match,
    required this.onRegister,
  });

  final _VolunteerMatch match;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final opportunity = match.opportunity;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.contact.program,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${opportunity.calendarEvent.date} • ${opportunity.calendarEvent.region}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: appTextMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _MatchStatusPill(score: match.totalScore),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Event fit for your profile and school selection.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appText,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _matchFactorEntries(match)
                .map(
                  (entry) => _MatchFactorTag(
                    label: entry.label,
                    strength: entry.value,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Suggested roles at this event: ${opportunity.contact.volunteerRoles}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Why this match: ${match.matchReason}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRegister,
            icon: Icon(
              opportunity.isRegistered
                  ? Icons.check_circle_outline
                  : Icons.app_registration_outlined,
            ),
            label: Text(
              opportunity.isRegistered ? 'Registered for Event' : 'Register for Event',
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchStatusPill extends StatelessWidget {
  const _MatchStatusPill({
    required this.score,
  });

  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [brandAccent, softGold],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _matchStatusLabel(score),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _MatchFactorTag extends StatelessWidget {
  const _MatchFactorTag({
    required this.label,
    required this.strength,
  });

  final String label;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final opacity = 0.28 + (strength.clamp(0.0, 1.0) * 0.72);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brandAccent.withValues(alpha: opacity),
            softGold.withValues(alpha: min(1.0, opacity + 0.08)),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: strength >= 0.58 ? Colors.white : brandAccentDark,
              fontWeight: FontWeight.w700,
            ),
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

class _VolunteerMatch {
  const _VolunteerMatch({
    required this.opportunity,
    required this.topicRelevance,
    required this.roleFit,
    required this.geographicProximity,
    required this.calendarFit,
    required this.historicalConversionRate,
    required this.studentInterestSignal,
    required this.totalScore,
    required this.matchReason,
  });

  final _VolunteerOpportunity opportunity;
  final double topicRelevance;
  final double roleFit;
  final double geographicProximity;
  final double calendarFit;
  final double historicalConversionRate;
  final double studentInterestSignal;
  final double totalScore;
  final String matchReason;
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

List<_VolunteerMatch> _scoreVolunteerMatches(
  AppAccount account,
  List<_VolunteerOpportunity> opportunities,
) {
  const weights = (
    topic: 0.24,
    role: 0.18,
    geographic: 0.14,
    calendar: 0.14,
    history: 0.14,
    interest: 0.16,
  );

  final results = opportunities.map((opportunity) {
    final topic = _topicRelevance(account, opportunity);
    final role = _roleFit(account, opportunity);
    final geographic = _geographicProximity(account, opportunity);
    final calendar = _calendarFit(opportunity);
    final history = _historicalConversionRate(account, opportunity);
    final interest = _studentInterestSignal(opportunity);

    final total = (weights.topic * topic) +
        (weights.role * role) +
        (weights.geographic * geographic) +
        (weights.calendar * calendar) +
        (weights.history * history) +
        (weights.interest * interest);

    return _VolunteerMatch(
      opportunity: opportunity,
      topicRelevance: topic,
      roleFit: role,
      geographicProximity: geographic,
      calendarFit: calendar,
      historicalConversionRate: history,
      studentInterestSignal: interest,
      totalScore: total,
      matchReason: _buildMatchReason(
        topic: topic,
        role: role,
        geographic: geographic,
        calendar: calendar,
        history: history,
        interest: interest,
      ),
    );
  }).toList()
    ..sort((left, right) {
      final scoreCompare = right.totalScore.compareTo(left.totalScore);
      if (scoreCompare != 0) return scoreCompare;
      return DateTime.parse(left.opportunity.calendarEvent.date).compareTo(
        DateTime.parse(right.opportunity.calendarEvent.date),
      );
    });

  return results;
}

double _topicRelevance(AppAccount account, _VolunteerOpportunity opportunity) {
  final volunteerText =
      '${account.memberLabel} ${account.fullName} ${account.email} '
      '${account.interests.join(' ')} ${account.expertise.join(' ')}';
  final opportunityText =
      '${opportunity.contact.category} ${opportunity.contact.program} '
      '${opportunity.calendarEvent.courseAlignment} '
      '${opportunity.contact.volunteerRoles} '
      '${opportunity.contact.audience}';
  return _cosineSimilarity(
    _tokenVector(volunteerText),
    _tokenVector(opportunityText),
  );
}

double _roleFit(AppAccount account, _VolunteerOpportunity opportunity) {
  final preferredRoles = _preferredRolesForLabel(account.memberLabel);
  final roles = opportunity.contact.volunteerRoles
      .toLowerCase()
      .split(';')
      .map((role) => role.trim())
      .toList();
  if (roles.isEmpty) return 0.25;
  if (roles.any(preferredRoles.contains)) return 1.0;
  if (roles.any((role) => role.contains('speaker')) &&
      account.memberLabel == 'Professional') {
    return 0.86;
  }
  if (roles.any((role) => role.contains('mentor')) &&
      account.memberLabel == 'Mentee') {
    return 0.72;
  }
  return 0.42;
}

double _geographicProximity(
  AppAccount account,
  _VolunteerOpportunity opportunity,
) {
  final homeMetro = _homeMetroFor(account);
  final region = opportunity.calendarEvent.region.toLowerCase();
  if (region.contains(homeMetro.toLowerCase())) return 1.0;
  if (region.contains('los angeles') && homeMetro == 'Pomona') return 0.9;
  if (region.contains('orange county') && homeMetro == 'Pomona') return 0.75;
  if (region.contains('ventura') && homeMetro == 'Los Angeles') return 0.72;
  if (region.contains('san diego') && homeMetro == 'Los Angeles') return 0.52;
  return 0.38;
}

double _calendarFit(_VolunteerOpportunity opportunity) {
  final eventDate = DateTime.parse(opportunity.calendarEvent.date);
  final today = DateTime.now();
  final daysAway = eventDate.difference(today).inDays.abs();
  if (daysAway <= 14) return 1.0;
  if (daysAway <= 30) return 0.82;
  if (daysAway <= 60) return 0.66;
  if (daysAway <= 120) return 0.48;
  return 0.32;
}

double _historicalConversionRate(
  AppAccount account,
  _VolunteerOpportunity opportunity,
) {
  final seed = _stableSeed(
    '${account.uid}-${opportunity.contact.category}-${opportunity.calendarEvent.region}',
  );
  final baseline = 0.45 + ((seed % 35) / 100);
  if (opportunity.contact.category.toLowerCase().contains('career')) {
    return min(1.0, baseline + 0.12);
  }
  if (opportunity.contact.category.toLowerCase().contains('hackathon')) {
    return min(1.0, baseline + 0.08);
  }
  return min(1.0, baseline);
}

double _studentInterestSignal(_VolunteerOpportunity opportunity) {
  var score = 0.4;
  final text =
      '${opportunity.contact.category} ${opportunity.contact.program} ${opportunity.contact.audience}'
          .toLowerCase();
  if (text.contains('hackathon') || text.contains('ai')) score += 0.2;
  if (text.contains('career') || text.contains('employer')) score += 0.18;
  if (text.contains('students')) score += 0.08;
  if (text.contains('research')) score += 0.06;
  return score.clamp(0.0, 1.0);
}

String _buildMatchReason({
  required double topic,
  required double role,
  required double geographic,
  required double calendar,
  required double history,
  required double interest,
}) {
  final factors = <String, double>{
    'topic fit': topic,
    'role fit': role,
    'geographic proximity': geographic,
    'calendar fit': calendar,
    'conversion history': history,
    'student demand': interest,
  }.entries.toList()
    ..sort((left, right) => right.value.compareTo(left.value));

  return 'Strongest drivers: ${factors[0].key}, ${factors[1].key}, and ${factors[2].key}.';
}

List<String> _preferredRolesForLabel(String memberLabel) {
  return switch (memberLabel) {
    'Mentee' => ['volunteer', 'mentor', 'guest speaker'],
    'Professional' => ['speaker', 'mentor', 'panelist', 'judge'],
    'Corporate' => ['judge', 'panelist', 'speaker'],
    _ => ['volunteer', 'mentor', 'judge'],
  };
}

String _homeMetroFor(AppAccount account) {
  final lower = account.email.toLowerCase();
  if (lower.contains('cpp') || lower.contains('pomona')) return 'Pomona';
  final seed = _stableSeed(account.uid);
  return switch (seed % 4) {
    0 => 'Pomona',
    1 => 'Los Angeles',
    2 => 'Orange County',
    _ => 'San Diego',
  };
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

int _stableSeed(String value) {
  var hash = 0;
  for (final codeUnit in value.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return hash;
}

String _matchStatusLabel(double score) {
  if (score >= 0.82) return 'Top Match';
  if (score >= 0.68) return 'Strong Match';
  if (score >= 0.52) return 'Good Match';
  return 'Possible Match';
}

List<({String label, double value})> _matchFactorEntries(_VolunteerMatch match) {
  final entries = <({String label, double value})>[
    (label: 'Topic Fit', value: match.topicRelevance),
    (label: 'Role Fit', value: match.roleFit),
    (label: 'Geo Fit', value: match.geographicProximity),
    (label: 'Calendar Fit', value: match.calendarFit),
    (label: 'History', value: match.historicalConversionRate),
    (label: 'Interest', value: match.studentInterestSignal),
  ]..sort((left, right) => right.value.compareTo(left.value));

  return entries;
}
