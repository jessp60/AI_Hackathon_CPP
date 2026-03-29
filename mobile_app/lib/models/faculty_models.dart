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

List<FacultyOpportunity> buildFacultyOpportunities() {
  final matchingContacts = campusContacts.where((contact) {
    final roles = contact.volunteerRoles.toLowerCase();
    return roles.contains('judge') ||
        roles.contains('speaker') ||
        roles.contains('panelist') ||
        roles.contains('reviewer') ||
        roles.contains('mentor');
  }).toList(growable: false);

  return List.generate(matchingContacts.length, (index) {
    final contact = matchingContacts[index];
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
