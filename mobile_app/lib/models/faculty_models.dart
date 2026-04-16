import 'app_models.dart';
import 'campus_data.dart';

enum VolunteerRequestStatus { sent, inReview, approved }

extension VolunteerRequestStatusX on VolunteerRequestStatus {
  String get label {
    return switch (this) {
      VolunteerRequestStatus.sent => 'Sent',
      VolunteerRequestStatus.inReview => 'In Review',
      VolunteerRequestStatus.approved => 'Approved',
    };
  }
}

class FacultyOpportunity {
  const FacultyOpportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.dateLabel,
    required this.region,
    required this.roles,
    required this.summary,
    required this.publicUrl,
    required this.contactName,
    required this.contactInfo,
  });

  final String id;
  final String title;
  final String organization;
  final String dateLabel;
  final String region;
  final String roles;
  final String summary;
  final String publicUrl;
  final String contactName;
  final String contactInfo;
}

class FacultyVolunteerRequest {
  const FacultyVolunteerRequest({
    required this.opportunityId,
    required this.status,
    required this.resumeName,
    required this.roleRequested,
  });

  final String opportunityId;
  final VolunteerRequestStatus status;
  final String resumeName;
  final String roleRequested;
}

List<FacultyOpportunity> buildFacultyOpportunities(AppAccount account) {
  final matchingContacts = campusContacts.where((contact) {
    final roles = contact.volunteerRoles.toLowerCase();
    final schoolScopedText =
        '${contact.program} ${contact.hostUnit} ${contact.publicUrl} ${contact.audience}';
    final matchesSchool = schoolMatchesOpportunity(account, schoolScopedText);
    return matchesSchool &&
        (roles.contains('judge') ||
        roles.contains('speaker') ||
        roles.contains('panelist') ||
        roles.contains('reviewer') ||
        roles.contains('mentor'));
  }).toList(growable: false);

  final scopedContacts = matchingContacts.isEmpty
      ? _fallbackContactsForOrganization(account.schoolOrganization)
      : matchingContacts;

  return List.generate(scopedContacts.length, (index) {
    final contact = scopedContacts[index];
    final calendar = calendarEvents[index % calendarEvents.length];
    return FacultyOpportunity(
      id: 'faculty-opp-$index',
      title: contact.program,
      organization: contact.hostUnit,
      dateLabel: calendar.date,
      region: calendar.region,
      roles: contact.volunteerRoles,
      summary:
          'Public opportunity for ${contact.category.toLowerCase()} support with ${_roleSummary(contact.volunteerRoles)}',
      publicUrl: contact.publicUrl,
      contactName: contact.contactName,
      contactInfo: contact.contactInfo,
    );
  });
}

List<CampusContact> _fallbackContactsForOrganization(
  SchoolOrganization organization,
) {
  return switch (organization) {
    SchoolOrganization.uc => const [
        CampusContact(
          program: 'UC Regional Research Symposium',
          category: 'Research symposium',
          recurrence: 'Annual',
          hostUnit: 'University of California network',
          volunteerRoles: 'Guest speaker; Panelist; Reviewer',
          audience: 'UC students and faculty',
          publicUrl: 'https://admission.universityofcalifornia.edu/',
          contactName: 'UC campus event teams',
          contactInfo: 'See campus event page',
        ),
        CampusContact(
          program: 'UC Career Fair Speaker Series',
          category: 'Career fair',
          recurrence: 'Recurring',
          hostUnit: 'University of California career centers',
          volunteerRoles: 'Panelist; Guest speaker',
          audience: 'Students across the UC system',
          publicUrl: 'https://admission.universityofcalifornia.edu/',
          contactName: 'UC career teams',
          contactInfo: 'See campus event page',
        ),
      ],
    SchoolOrganization.privateSchool => const [
        CampusContact(
          program: 'Independent University Leadership Panel',
          category: 'Career panel',
          recurrence: 'Recurring',
          hostUnit: 'Private university network',
          volunteerRoles: 'Panelist; Guest speaker; Mentor',
          audience: 'Students and alumni',
          publicUrl: 'https://www.aiccu.edu/',
          contactName: 'Campus leadership programs',
          contactInfo: 'See campus event page',
        ),
      ],
    _ => const [],
  };
}

String recommendedRoleForOpportunity(
  FacultyOpportunity opportunity,
  AppAccount account,
) {
  final lowerRoles = opportunity.roles.toLowerCase();
  final lowerPosition = (account.facultyPosition ?? '').toLowerCase();

  if (lowerRoles.contains('judge') &&
      (lowerPosition.contains('professor') ||
          lowerPosition.contains('director') ||
          lowerPosition.contains('chair'))) {
    return 'Judge';
  }
  if (lowerRoles.contains('panelist') && lowerPosition.contains('career')) {
    return 'Panelist';
  }
  if (lowerRoles.contains('speaker') &&
      (lowerPosition.contains('research') ||
          lowerPosition.contains('professor') ||
          lowerPosition.contains('faculty'))) {
    return 'Guest Speaker';
  }
  if (lowerRoles.contains('mentor')) return 'Mentor';

  return opportunity.roles.split(';').first.trim();
}

String _roleSummary(String roles) {
  final cleanedRoles = roles
      .split(';')
      .map((role) => role.trim())
      .where((role) => role.isNotEmpty)
      .toList();
  if (cleanedRoles.isEmpty) {
    return 'general volunteer support';
  }
  if (cleanedRoles.length == 1) return cleanedRoles.first.toLowerCase();
  return '${cleanedRoles.first.toLowerCase()} and related event leadership roles';
}
