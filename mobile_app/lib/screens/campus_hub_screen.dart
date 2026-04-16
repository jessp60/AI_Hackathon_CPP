import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../models/campus_data.dart';
import '../theme_constants.dart';
import '../utils/in_app_link_opener.dart';

const _iaWestMembershipUrl =
    'https://www.insightsassociation.org/Membership/Chapters/West';

class CampusHubScreen extends StatelessWidget {
  const CampusHubScreen({
    super.key,
    required this.account,
    this.historySignals = const [],
  });

  final AppAccount account;
  final List<String> historySignals;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filteredEvents = _filteredCalendarEvents(account, historySignals);
    final filteredSpeakers = _filteredSpeakerProfiles(account);
    final filteredContacts = _filteredCampusContacts(account);
    final filteredSchedule = _filteredCourseSchedule(account);
    final filteredFeeds = _filteredUniversityFeeds(account);

    return DefaultTabController(
      length: 5,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IA Hub',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                  //   Text(
                  // 'An IA-specific hub of events, speakers, contacts, schedules, and approved public feeds matched to your school, subjects, and engagement history.',
                  //     style: textTheme.bodyLarge?.copyWith(
                  //       color: appTextMuted,
                  //       height: 1.35,
                  //     ),
                  //   ),
                    const SizedBox(height: 14),
                    _PersonalizedHubCard(
                      account: account,
                      filteredEvents: filteredEvents.length,
                      filteredSpeakers: filteredSpeakers.length,
                      filteredContacts: filteredContacts.length,
                      filteredFeeds: filteredFeeds.length,
                    ),
                    if (account.isStudent) ...[
                      const SizedBox(height: 14),
                      _IaMembershipCard(account: account),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Events',
                            value: '${filteredEvents.length}',
                            icon: Icons.event_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Speakers',
                            value: '${filteredSpeakers.length}',
                            icon: Icons.record_voice_over_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Contacts',
                            value: '${filteredContacts.length}',
                            icon: Icons.contact_mail_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _HubTabBarDelegate(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: mutedSurface),
                    ),
                    child: const TabBar(
                      isScrollable: true,
                      indicatorColor: brandAccent,
                      labelColor: brandAccentDark,
                      unselectedLabelColor: appTextMuted,
                      tabs: [
                        Tab(text: 'Events'),
                        Tab(text: 'Speakers'),
                        Tab(text: 'Contacts'),
                        Tab(text: 'Schedule'),
                        Tab(text: 'Feeds'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _CalendarTab(events: filteredEvents),
            _SpeakersTab(speakers: filteredSpeakers),
            _ContactsTab(contacts: filteredContacts),
            _ScheduleTab(scheduleItems: filteredSchedule),
            _FeedImportsTab(feedItems: filteredFeeds, account: account),
          ],
        ),
      ),
    );
  }
}

class _HubTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _HubTabBarDelegate({
    required this.child,
  });

  final Widget child;

  @override
  double get minExtent => 62;

  @override
  double get maxExtent => 62;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: appBackground,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _HubTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _PersonalizedHubCard extends StatelessWidget {
  const _PersonalizedHubCard({
    required this.account,
    required this.filteredEvents,
    required this.filteredSpeakers,
    required this.filteredContacts,
    required this.filteredFeeds,
  });

  final AppAccount account;
  final int filteredEvents;
  final int filteredSpeakers;
  final int filteredContacts;
  final int filteredFeeds;

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
          Text(
            'Customized for ${account.schoolName}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Showing content matched to your school system plus your selected interests and expertise: ${account.interests.join(', ')}.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeedChip(
                icon: Icons.event_note_outlined,
                label: '$filteredEvents matched events',
              ),
              _FeedChip(
                icon: Icons.people_outline,
                label: '$filteredSpeakers relevant speakers',
              ),
              _FeedChip(
                icon: Icons.contact_phone_outlined,
                label: '$filteredContacts outreach contacts',
              ),
              _FeedChip(
                icon: Icons.public_outlined,
                label: '$filteredFeeds public feeds',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IaMembershipCard extends StatelessWidget {
  const _IaMembershipCard({
    required this.account,
  });

  final AppAccount account;

  Future<void> _openMembershipPage() async {
    await openInAppLink(_iaWestMembershipUrl);
  }

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
          Text(
            'Become an IA West Member',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to go beyond event attendance at ${account.schoolName}? Open the official IA West page to explore chapter involvement and membership pathways.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appTextMuted,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _openMembershipPage,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Become an IA Member'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appTextMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({
    required this.events,
  });

  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return _HubCard(
          title: '${event.region} • ${event.date}',
          subtitle: event.lectureWindow,
          children: [
            _InfoLine(label: 'Nearby Universities', value: event.nearbyUniversities),
            _InfoLine(label: 'Course Alignment', value: event.courseAlignment),
          ],
        );
      },
    );
  }
}

class _SpeakersTab extends StatelessWidget {
  const _SpeakersTab({
    required this.speakers,
  });

  final List<SpeakerProfile> speakers;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: speakers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final speaker = speakers[index];
        return _HubCard(
          title: speaker.name,
          subtitle: '${speaker.boardRole} • ${speaker.company}',
          children: [
            _InfoLine(label: 'Title', value: speaker.title),
            _InfoLine(label: 'Metro Region', value: speaker.metroRegion),
            _InfoLine(label: 'Expertise', value: speaker.expertiseTags),
          ],
        );
      },
    );
  }
}

class _ContactsTab extends StatelessWidget {
  const _ContactsTab({
    required this.contacts,
  });

  final List<CampusContact> contacts;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _HubCard(
          title: contact.program,
          subtitle: '${contact.category} • ${contact.recurrence}',
          children: [
            _InfoLine(label: 'Host / Unit', value: contact.hostUnit),
            _InfoLine(label: 'Volunteer Roles', value: contact.volunteerRoles),
            _InfoLine(label: 'Audience', value: contact.audience),
            _InfoLine(label: 'Contact', value: contact.contactName),
            _InfoLine(label: 'Email / Phone', value: contact.contactInfo),
            _InfoLine(label: 'Public URL', value: contact.publicUrl),
          ],
        );
      },
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({
    required this.scheduleItems,
  });

  final List<CourseScheduleItem> scheduleItems;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: scheduleItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = scheduleItems[index];
        return _HubCard(
          title: '${item.course}-${item.section} • ${item.title}',
          subtitle: '${item.days} • ${item.startTime}–${item.endTime}',
          children: [
            _InfoLine(label: 'Instructor', value: item.instructor),
            _InfoLine(label: 'Mode', value: item.mode),
            _InfoLine(label: 'Guest Lecture Fit', value: item.guestLectureFit),
            _InfoLine(label: 'Enrollment Cap', value: item.enrollmentCap),
          ],
        );
      },
    );
  }
}

class _FeedImportsTab extends StatelessWidget {
  const _FeedImportsTab({
    required this.feedItems,
    required this.account,
  });

  final List<UniversityFeedEvent> feedItems;
  final AppAccount account;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: feedItems.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _HubCard(
            title: 'Approved Public Event Feeds',
            subtitle: 'Ethical sourcing for ${account.schoolName} opportunities',
            children: const [
              _InfoLine(
                label: 'Policy',
                value:
                    'Only ingest public, allowlisted university pages with source attribution, light rate limits, and admin review before surfacing to students.',
              ),
              _InfoLine(
                label: 'Why this matters',
                value:
                    'This keeps the app useful for networking while avoiding hidden scraping, private data capture, or misleading event listings.',
              ),
              SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeedChip(
                    icon: Icons.public_outlined,
                    label: 'Public pages only',
                  ),
                  _FeedChip(
                    icon: Icons.verified_outlined,
                    label: 'Source attributed',
                  ),
                  _FeedChip(
                    icon: Icons.speed_outlined,
                    label: 'Light refreshes',
                  ),
                  _FeedChip(
                    icon: Icons.fact_check_outlined,
                    label: 'Human reviewed',
                  ),
                ],
              ),
            ],
          );
        }

        final item = feedItems[index - 1];
        return _HubCard(
          title: item.title,
          subtitle: '${item.university} • ${item.eventDate}',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FeedChip(
                  icon: Icons.sell_outlined,
                  label: item.category,
                ),
                _FeedChip(
                  icon: Icons.language_outlined,
                  label: item.sourceSite,
                ),
                _FeedChip(
                  icon: item.reviewStatus.startsWith('Reviewed')
                      ? Icons.verified_outlined
                      : Icons.pending_outlined,
                  label: item.reviewStatus,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoLine(label: 'Summary', value: item.summary),
            _InfoLine(label: 'Networking Value', value: item.networkingValue),
            _InfoLine(label: 'Ethics Note', value: item.ethicsNote),
            _InfoLine(label: 'Source URL', value: item.sourceUrl),
          ],
        );
      },
    );
  }
}

class _FeedChip extends StatelessWidget {
  const _FeedChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: softBlush,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: mutedSurface),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: brandAccentDark,
          ),
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

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appTextMuted,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  bool get _isUrl => value.startsWith('http://') || value.startsWith('https://');

  Future<void> _openUrl() async {
    await openInAppLink(value);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: appText,
          height: 1.35,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: textStyle?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (_isUrl)
            InkWell(
              onTap: _openUrl,
              child: Text(
                value,
                style: textStyle?.copyWith(
                  color: brandAccentDark,
                  decoration: TextDecoration.underline,
                  decorationColor: brandAccentDark,
                ),
              ),
            )
          else
            Text(
              value,
              style: textStyle,
            ),
        ],
      ),
    );
  }
}

List<CalendarEvent> _filteredCalendarEvents(
  AppAccount account,
  List<String> historySignals,
) {
  final filtered = calendarEvents.where((event) {
    final haystack =
        '${event.region} ${event.nearbyUniversities} ${event.courseAlignment}';
    return schoolMatchesOpportunity(account, haystack) ||
        _matchesSubjects(account, haystack);
  }).toList(growable: false);
  final candidates =
      filtered.isEmpty ? calendarEvents.take(4).toList(growable: false) : filtered;
  candidates.sort(
    (left, right) => _eventRelevanceScore(
      account,
      right,
      historySignals,
    ).compareTo(
      _eventRelevanceScore(account, left, historySignals),
    ),
  );
  return candidates;
}

List<SpeakerProfile> _filteredSpeakerProfiles(AppAccount account) {
  final filtered = speakerProfiles.where((speaker) {
    final haystack =
        '${speaker.name} ${speaker.metroRegion} ${speaker.company} ${speaker.title} ${speaker.expertiseTags}';
    return schoolMatchesOpportunity(account, haystack) ||
        _matchesSubjects(account, haystack);
  }).toList(growable: false);
  return filtered.isEmpty ? speakerProfiles.take(4).toList(growable: false) : filtered;
}

List<CampusContact> _filteredCampusContacts(AppAccount account) {
  final filtered = campusContacts.where((contact) {
    final haystack =
        '${contact.program} ${contact.category} ${contact.hostUnit} ${contact.volunteerRoles} ${contact.audience} ${contact.publicUrl}';
    return schoolMatchesOpportunity(account, haystack) ||
        _matchesSubjects(account, haystack);
  }).toList(growable: false);
  return filtered.isEmpty ? campusContacts.take(4).toList(growable: false) : filtered;
}

List<CourseScheduleItem> _filteredCourseSchedule(AppAccount account) {
  final filtered = courseSchedule.where((item) {
    final haystack =
        '${item.instructor} ${item.course} ${item.title} ${item.guestLectureFit}';
    return schoolMatchesOpportunity(account, haystack) ||
        _matchesSubjects(account, haystack);
  }).toList(growable: false);
  return filtered.isEmpty ? courseSchedule.take(4).toList(growable: false) : filtered;
}

List<UniversityFeedEvent> _filteredUniversityFeeds(AppAccount account) {
  final filtered = universityFeedEvents.where((item) {
    final haystack =
        '${item.title} ${item.university} ${item.category} ${item.summary} ${item.networkingValue} ${item.sourceUrl}';
    return schoolMatchesOpportunity(account, haystack) ||
        _matchesSubjects(account, haystack);
  }).toList(growable: false);
  return filtered.isEmpty
      ? universityFeedEvents.take(4).toList(growable: false)
      : filtered;
}

bool _matchesSubjects(AppAccount account, String haystack) {
  final lowerHaystack = haystack.toLowerCase();
  final tokens = {...account.interests, ...account.expertise}
      .map((item) => item.toLowerCase())
      .toList(growable: false);
  return tokens.any((token) => lowerHaystack.contains(token));
}

double _eventRelevanceScore(
  AppAccount account,
  CalendarEvent event,
  List<String> historySignals,
) {
  final haystack =
      '${event.region} ${event.nearbyUniversities} ${event.lectureWindow} ${event.courseAlignment}';
  final interestText = account.interests.join(' ');
  final expertiseText = account.expertise.join(' ');
  final historyText = historySignals.join(' ');
  final schoolBoost = schoolMatchesOpportunity(account, haystack) ? 0.22 : 0.0;

  return (_cosineSimilarity(
            _tokenVector(interestText),
            _tokenVector(haystack),
          ) *
          0.4) +
      (_cosineSimilarity(
            _tokenVector(expertiseText),
            _tokenVector(haystack),
          ) *
          0.35) +
      (_cosineSimilarity(
            _tokenVector(historyText),
            _tokenVector(haystack),
          ) *
          0.25) +
      schoolBoost;
}

Map<String, double> _tokenVector(String value) {
  final tokens = RegExp(r'[a-zA-Z0-9]+')
      .allMatches(value.toLowerCase())
      .map((match) => match.group(0)!)
      .toList(growable: false);
  final counts = <String, double>{};
  for (final token in tokens) {
    counts.update(token, (current) => current + 1, ifAbsent: () => 1);
  }
  return counts;
}

double _cosineSimilarity(
  Map<String, double> left,
  Map<String, double> right,
) {
  if (left.isEmpty || right.isEmpty) return 0;

  var dotProduct = 0.0;
  var leftMagnitude = 0.0;
  var rightMagnitude = 0.0;

  for (final entry in left.entries) {
    leftMagnitude += entry.value * entry.value;
    final rightValue = right[entry.key];
    if (rightValue != null) {
      dotProduct += entry.value * rightValue;
    }
  }

  for (final value in right.values) {
    rightMagnitude += value * value;
  }

  if (leftMagnitude == 0 || rightMagnitude == 0) return 0;
  return dotProduct / (math.sqrt(leftMagnitude) * math.sqrt(rightMagnitude));
}
