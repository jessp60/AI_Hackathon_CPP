import 'package:flutter/material.dart';

import '../models/campus_data.dart';
import '../theme_constants.dart';

class CampusHubScreen extends StatelessWidget {
  const CampusHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 4,
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
                  'Real event windows, speaker profiles, published contact info, and the CPP course schedule seeded from your CSV files.',
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
                  Tab(text: 'Results'),
                  Tab(text: 'Speakers'),
                  Tab(text: 'Contacts'),
                  Tab(text: 'Schedule'),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: appText,
                height: 1.35,
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
