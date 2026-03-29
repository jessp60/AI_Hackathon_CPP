import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/campus_data.dart';
import '../theme_constants.dart';

class CampusHubScreen extends StatelessWidget {
  const CampusHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus Hub',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Real event windows, speaker profiles, published contact info, the CPP course schedule, and reviewable university feed imports.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: appTextMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Events',
                        value: '${calendarEvents.length}',
                        icon: Icons.event_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Speakers',
                        value: '${speakerProfiles.length}',
                        icon: Icons.record_voice_over_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Contacts',
                        value: '${campusContacts.length}',
                        icon: Icons.contact_mail_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 12),
          const Expanded(
            child: TabBarView(
              children: [
                _CalendarTab(),
                _SpeakersTab(),
                _ContactsTab(),
                _ScheduleTab(),
                _FeedImportsTab(),
              ],
            ),
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
  const _CalendarTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: calendarEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = calendarEvents[index];
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
  const _SpeakersTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: speakerProfiles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final speaker = speakerProfiles[index];
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
  const _ContactsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: campusContacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contact = campusContacts[index];
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
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: courseSchedule.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = courseSchedule[index];
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
  const _FeedImportsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: universityFeedEvents.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _HubCard(
            title: 'Approved Public Event Feeds',
            subtitle: 'Ethical sourcing for student networking opportunities',
            children: [
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

        final item = universityFeedEvents[index - 1];
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
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.platformDefault);
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
