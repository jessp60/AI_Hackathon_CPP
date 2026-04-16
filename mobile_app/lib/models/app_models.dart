import 'package:firebase_auth/firebase_auth.dart';

import 'campus_data.dart';

enum AppAccountType { student, faculty }
enum SchoolOrganization { csu, uc, privateSchool, other }

const schoolSubjects = [
  'Marketing',
  'Finance',
  'Accounting',
  'Management',
  'Entrepreneurship',
  'Information Systems',
  'Computer Science',
  'Data Science',
  'Artificial Intelligence',
  'Research Methods',
  'Economics',
  'Design',
  'Healthcare',
  'Sustainability',
  'Education',
];

class AppAccount {
  const AppAccount({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.accountType,
    required this.schoolName,
    required this.schoolOrganization,
    this.selectedSchools = const [],
    this.interests = const [],
    this.expertise = const [],
    this.photoUrl,
    this.facultyPosition,
    this.isFacultyVerified = false,
  });

  final String uid;
  final String fullName;
  final String email;
  final AppAccountType accountType;
  final String schoolName;
  final SchoolOrganization schoolOrganization;
  final List<String> selectedSchools;
  final List<String> interests;
  final List<String> expertise;
  final String? photoUrl;
  final String? facultyPosition;
  final bool isFacultyVerified;

  bool get isFaculty => accountType == AppAccountType.faculty;
  bool get isStudent => accountType == AppAccountType.student;

  String get memberLabel {
    if (isFaculty) return 'Board Member';
    final normalized = email.trim().toLowerCase();
    if (normalized.endsWith('.edu')) return 'Student';
    final seed = _stableHash(normalized.isEmpty ? uid : normalized);
    return switch (seed % 4) {
      0 => 'Mentee',
      1 => 'Student',
      2 => 'Professional',
      _ => 'Corporate',
    };
  }

  String get initials {
    final parts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory AppAccount.fromFirebaseUser(User user) {
    final parsed = _parseAccountProfile(
      user.displayName,
      fallbackEmail: user.email ?? '',
      fallbackUid: user.uid,
    );
    final emailPrefix = user.email?.split('@').first.trim() ?? 'student';
    return AppAccount(
      uid: user.uid,
      fullName: parsed.fullName.isNotEmpty
          ? parsed.fullName
          : emailPrefix.replaceAll(RegExp(r'[._-]+'), ' '),
      email: user.email ?? '',
      accountType: parsed.accountType,
      schoolName: parsed.schoolName,
      schoolOrganization: organizationForSchool(parsed.schoolName),
      selectedSchools: parsed.selectedSchools,
      interests: parsed.interests,
      expertise: parsed.expertise,
      photoUrl: user.photoURL?.trim().isEmpty ?? true ? null : user.photoURL,
      facultyPosition: parsed.facultyPosition,
      isFacultyVerified: parsed.isFacultyVerified,
    );
  }

  static String encodeDisplayName({
    required String fullName,
    required AppAccountType accountType,
    required String schoolName,
    List<String>? selectedSchools,
    required List<String> interests,
    required List<String> expertise,
    String? facultyPosition,
    bool isFacultyVerified = false,
  }) {
    final safeName = fullName.trim().isEmpty ? 'BroncoBoost Member' : fullName.trim();
    final safePosition = (facultyPosition ?? '').replaceAll('|', '/').trim();
    final safeSchool = schoolName.replaceAll('|', '/').trim();
    final safeSelectedSchools = (selectedSchools ?? [schoolName])
        .map(_metadataSafeValue)
        .join(',');
    final safeInterests = interests.map(_metadataSafeValue).join(',');
    final safeExpertise = expertise.map(_metadataSafeValue).join(',');
    final accountTypeLabel = accountType == AppAccountType.faculty ? 'faculty' : 'student';
    final verifiedLabel = isFacultyVerified ? 'verified' : 'pending';
    return '$safeName [[bb|$accountTypeLabel|$safePosition|$verifiedLabel|$safeSchool|$safeInterests|$safeExpertise|$safeSelectedSchools]]';
  }

  AppAccount copyWith({
    String? uid,
    String? fullName,
    String? email,
    AppAccountType? accountType,
    String? schoolName,
    SchoolOrganization? schoolOrganization,
    List<String>? selectedSchools,
    List<String>? interests,
    List<String>? expertise,
    Object? photoUrl = _noPhotoUrlOverride,
    Object? facultyPosition = _noPhotoUrlOverride,
    bool? isFacultyVerified,
  }) {
    return AppAccount(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      accountType: accountType ?? this.accountType,
      schoolName: schoolName ?? this.schoolName,
      schoolOrganization: schoolOrganization ?? this.schoolOrganization,
      selectedSchools: selectedSchools ?? this.selectedSchools,
      interests: interests ?? this.interests,
      expertise: expertise ?? this.expertise,
      photoUrl: identical(photoUrl, _noPhotoUrlOverride)
          ? this.photoUrl
          : photoUrl as String?,
      facultyPosition: identical(facultyPosition, _noPhotoUrlOverride)
          ? this.facultyPosition
          : facultyPosition as String?,
      isFacultyVerified: isFacultyVerified ?? this.isFacultyVerified,
    );
  }
}

const _noPhotoUrlOverride = Object();

class EventItem {
  const EventItem({
    required this.name,
    required this.dateLabel,
    required this.location,
    required this.xpReward,
  });

  final String name;
  final String dateLabel;
  final String location;
  final int xpReward;
}

class SchoolEventAlert {
  const SchoolEventAlert({
    required this.id,
    required this.title,
    required this.summary,
    required this.eventDate,
    required this.sourceUrl,
    required this.sourceSite,
  });

  final String id;
  final String title;
  final String summary;
  final String eventDate;
  final String sourceUrl;
  final String sourceSite;
}

class CityUnlock {
  const CityUnlock({
    required this.name,
    required this.unlocked,
  });

  final String name;
  final bool unlocked;
}

class SimpleState {
  const SimpleState({
    required this.rank,
    required this.level,
    required this.totalXp,
    required this.currentXpIntoLevel,
    required this.xpForNextLevel,
    required this.avatarStage,
    required this.xpToNextStage,
    required this.events,
    required this.cities,
  });

  final int rank;
  final int level;
  final int totalXp;
  final int currentXpIntoLevel;
  final int xpForNextLevel;
  final String avatarStage;
  final int xpToNextStage;
  final List<EventItem> events;
  final List<CityUnlock> cities;

  double get levelProgress => currentXpIntoLevel / xpForNextLevel;

  String get farmStageTitle {
    if (totalXp >= 5000) return 'Champion Bronco';
    if (totalXp >= 3000) return 'Adult Bronco';
    if (totalXp >= 1500) return 'Young Bronco';
    if (totalXp >= 500) return 'Pony';
    return 'Tiny Pony';
  }

  int get farmStageNumber {
    if (totalXp >= 5000) return 5;
    if (totalXp >= 3000) return 4;
    if (totalXp >= 1500) return 3;
    if (totalXp >= 500) return 2;
    return 1;
  }

  List<String> get unlockedAccessories {
    final accessories = <String>[];
    if (totalXp >= 250) accessories.add('Bandana');
    if (totalXp >= 700) accessories.add('Trail Saddle');
    if (totalXp >= 1400) accessories.add('Bronco Ribbon');
    if (totalXp >= 2200) accessories.add('Lucky Horseshoes');
    if (totalXp >= 3200) accessories.add('Champion Blanket');
    if (totalXp >= 4500) accessories.add('Gold Bridle');
    return accessories;
  }

  int get unlockedHorseCount {
    if (totalXp >= 4800) return 4;
    if (totalXp >= 3200) return 3;
    if (totalXp >= 1800) return 2;
    return 1;
  }

  int get xpForNextFarmStage {
    if (farmStageNumber == 1) return 500;
    if (farmStageNumber == 2) return 1500;
    if (farmStageNumber == 3) return 3000;
    if (farmStageNumber == 4) return 5000;
    return 7000;
  }

  String get nextFarmStageTitle {
    if (farmStageNumber == 1) return 'Pony';
    if (farmStageNumber == 2) return 'Young Bronco';
    if (farmStageNumber == 3) return 'Adult Bronco';
    if (farmStageNumber == 4) return 'Champion Bronco';
    return 'Champion Bronco';
  }

  double get farmProgress {
    final current = totalXp.clamp(0, xpForNextFarmStage);
    return current / xpForNextFarmStage;
  }

  String get officeStageTitle {
    if (totalXp >= 5000) return 'Corporate Member';
    if (totalXp >= 3000) return 'Young Professional';
    if (totalXp >= 1500) return 'Mentee Match';
    if (totalXp >= 500) return 'Local Event Attendee';
    return 'Student Member';
  }

  int get officeStageNumber {
    if (totalXp >= 5000) return 5;
    if (totalXp >= 3000) return 4;
    if (totalXp >= 1500) return 3;
    if (totalXp >= 500) return 2;
    return 1;
  }

  int get xpForNextOfficeStage {
    if (officeStageNumber == 1) return 500;
    if (officeStageNumber == 2) return 1500;
    if (officeStageNumber == 3) return 3000;
    if (officeStageNumber == 4) return 5000;
    return 7000;
  }

  String get nextOfficeStageTitle {
    if (officeStageNumber == 1) return 'Local Event Attendee';
    if (officeStageNumber == 2) return 'Mentee Match';
    if (officeStageNumber == 3) return 'Young Professional';
    if (officeStageNumber == 4) return 'Corporate Member';
    return 'Corporate Member';
  }

  double get officeProgress {
    final current = totalXp.clamp(0, xpForNextOfficeStage);
    return current / xpForNextOfficeStage;
  }
}

class SimpleRepository {
  static SimpleState stateFor(AppAccount account) {
    final normalizedIdentity =
        account.email.trim().toLowerCase().isNotEmpty
            ? account.email.trim().toLowerCase()
            : account.uid;
    final seed = _stableHash(normalizedIdentity);
    final totalXp = 900 + (seed % 4200);
    final currentXpIntoLevel = totalXp % 500;
    const xpForNextLevel = 500;
    final level = (totalXp ~/ xpForNextLevel) + 1;
    final xpToNextStage = _nextFarmThreshold(totalXp) - totalXp;
    return SimpleState(
      rank: 5 + (seed % 40),
      level: level,
      totalXp: totalXp,
      currentXpIntoLevel: currentXpIntoLevel,
      xpForNextLevel: xpForNextLevel,
      avatarStage: _farmStageTitleForXp(totalXp),
      xpToNextStage: xpToNextStage,
      events: _eventsForSchool(account),
      cities: const [
        CityUnlock(name: 'Pomona', unlocked: true),
        CityUnlock(name: 'Los Angeles', unlocked: true),
        CityUnlock(name: 'San Diego', unlocked: false),
        CityUnlock(name: 'San Francisco', unlocked: false),
      ],
    );
  }
}

List<EventItem> _eventsForSchool(AppAccount account) {
  return switch (account.schoolOrganization) {
    SchoolOrganization.uc => const [
        EventItem(
          name: 'UC Research Networking Panel',
          dateLabel: 'Thu, 4:30 PM',
          location: 'Regional UC Career Center',
          xpReward: 140,
        ),
        EventItem(
          name: 'UC Student Innovation Mixer',
          dateLabel: 'Fri, 6:00 PM',
          location: 'Innovation Commons',
          xpReward: 120,
        ),
        EventItem(
          name: 'University of California Career Speaker Series',
          dateLabel: 'Sat, 10:00 AM',
          location: 'Main Lecture Hall',
          xpReward: 180,
        ),
      ],
    SchoolOrganization.privateSchool => [
        EventItem(
          name: '${account.schoolName} Networking Night',
          dateLabel: 'Thu, 5:30 PM',
          location: 'Student Union',
          xpReward: 130,
        ),
        EventItem(
          name: '${account.schoolName} Career Workshop',
          dateLabel: 'Fri, 2:00 PM',
          location: 'Business Center',
          xpReward: 110,
        ),
        EventItem(
          name: '${account.schoolName} Mentor Meetup',
          dateLabel: 'Sat, 11:00 AM',
          location: 'Campus Commons',
          xpReward: 170,
        ),
      ],
    _ => const [
        EventItem(
          name: 'Startup Founder Panel',
          dateLabel: 'Today, 5:00 PM',
          location: 'Innovation Village',
          xpReward: 150,
        ),
        EventItem(
          name: 'CPP Networking Night',
          dateLabel: 'Fri, 6:30 PM',
          location: 'College of Business',
          xpReward: 120,
        ),
        EventItem(
          name: 'Hackathon Build Sprint',
          dateLabel: 'Sat, 10:00 AM',
          location: 'Library Lab',
          xpReward: 220,
        ),
      ],
  };
}

int _stableHash(String value) {
  var hash = 0;
  for (final codeUnit in value.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return hash;
}

int _nextFarmThreshold(int totalXp) {
  if (totalXp < 500) return 500;
  if (totalXp < 1500) return 1500;
  if (totalXp < 3000) return 3000;
  if (totalXp < 5000) return 5000;
  return 7000;
}

String _farmStageTitleForXp(int totalXp) {
  if (totalXp >= 5000) return 'Champion Bronco';
  if (totalXp >= 3000) return 'Adult Bronco';
  if (totalXp >= 1500) return 'Young Bronco';
  if (totalXp >= 500) return 'Pony';
  return 'Tiny Pony';
}

class _ParsedAccountProfile {
  const _ParsedAccountProfile({
    required this.fullName,
    required this.accountType,
    required this.schoolName,
    required this.selectedSchools,
    required this.interests,
    required this.expertise,
    this.facultyPosition,
    required this.isFacultyVerified,
  });

  final String fullName;
  final AppAccountType accountType;
  final String schoolName;
  final List<String> selectedSchools;
  final List<String> interests;
  final List<String> expertise;
  final String? facultyPosition;
  final bool isFacultyVerified;
}

_ParsedAccountProfile _parseAccountProfile(
  String? rawDisplayName, {
  required String fallbackEmail,
  required String fallbackUid,
}) {
  final displayName = rawDisplayName?.trim() ?? '';
  final metadataStart = displayName.lastIndexOf('[[bb|');
  if (metadataStart == -1 || !displayName.endsWith(']]')) {
    return _ParsedAccountProfile(
      fullName: displayName,
      accountType: AppAccountType.student,
      schoolName: 'Cal Poly Pomona',
      selectedSchools: const ['Cal Poly Pomona'],
      interests: const ['Marketing'],
      expertise: const ['Marketing'],
      facultyPosition: null,
      isFacultyVerified: false,
    );
  }

  final fullName = displayName.substring(0, metadataStart).trim();
  final metadata = displayName
      .substring(metadataStart + 5, displayName.length - 2)
      .split('|');

  final typeToken = metadata.isNotEmpty ? metadata[0].trim().toLowerCase() : 'student';
  final positionToken = metadata.length > 1 ? metadata[1].trim() : '';
  final verifiedToken = metadata.length > 2 ? metadata[2].trim().toLowerCase() : '';
  final schoolToken = metadata.length > 3 ? metadata[3].trim() : '';
  final interestsToken = metadata.length > 4 ? metadata[4].trim() : '';
  final expertiseToken = metadata.length > 5 ? metadata[5].trim() : '';
  final selectedSchoolsToken = metadata.length > 6 ? metadata[6].trim() : '';
  final parsedSchoolName = schoolToken.isEmpty ? 'Cal Poly Pomona' : schoolToken;
  final parsedSelectedSchools = _decodeOptionalMetadataList(selectedSchoolsToken);

  return _ParsedAccountProfile(
    fullName: fullName.isNotEmpty
        ? fullName
        : (fallbackEmail.split('@').first.trim().isNotEmpty
            ? fallbackEmail.split('@').first.trim()
            : fallbackUid),
    accountType: typeToken == 'faculty'
        ? AppAccountType.faculty
        : AppAccountType.student,
    schoolName: parsedSchoolName,
    selectedSchools: parsedSelectedSchools.isEmpty
        ? [parsedSchoolName]
        : parsedSelectedSchools,
    interests: _decodeMetadataList(interestsToken),
    expertise: _decodeMetadataList(expertiseToken),
    facultyPosition: positionToken.isEmpty ? null : positionToken,
    isFacultyVerified: verifiedToken == 'verified',
  );
}

SchoolOrganization organizationForSchool(String schoolName) {
  final lower = schoolName.toLowerCase();
  if (lower.contains('cal state') ||
      lower.contains('cal poly') ||
      lower.contains('csu') ||
      lower.contains('state university')) {
    return SchoolOrganization.csu;
  }
  if (lower.contains('university of california') ||
      lower.contains(RegExp(r'\buc\b')) ||
      lower.contains('ucla') ||
      lower.contains('uci') ||
      lower.contains('ucsd') ||
      lower.contains('berkeley')) {
    return SchoolOrganization.uc;
  }
  if (lower.contains('university') ||
      lower.contains('college') ||
      lower.contains('institute')) {
    return SchoolOrganization.privateSchool;
  }
  return SchoolOrganization.other;
}

bool schoolMatchesOpportunity(AppAccount account, String haystack) {
  final lowerHaystack = haystack.toLowerCase();
  final selectedSchools = account.selectedSchools.isEmpty
          ? [account.schoolName]
          : account.selectedSchools;
  final schools = selectedSchools
      .map((school) => school.toLowerCase())
      .toList(growable: false);
  if (schools.any(lowerHaystack.contains)) return true;

  final organizations = selectedSchools
      .map(organizationForSchool)
      .toSet();

  return organizations.any((organization) => switch (organization) {
    SchoolOrganization.csu =>
      lowerHaystack.contains('cal poly') ||
          lowerHaystack.contains('csu') ||
          lowerHaystack.contains('state university') ||
          lowerHaystack.contains('cpp') ||
          lowerHaystack.contains('csulb') ||
          lowerHaystack.contains('csuf') ||
          lowerHaystack.contains('csuci'),
    SchoolOrganization.uc =>
      lowerHaystack.contains('university of california') ||
          lowerHaystack.contains('ucla') ||
          lowerHaystack.contains('uci') ||
          lowerHaystack.contains('uc san diego') ||
          lowerHaystack.contains('ucsd') ||
          lowerHaystack.contains('berkeley'),
    SchoolOrganization.privateSchool =>
      schools.any((school) => lowerHaystack.contains(school.split(' ').first)),
    SchoolOrganization.other => false,
  });
}

bool matchesAccountSubjects(AppAccount account, String haystack) {
  final lowerHaystack = haystack.toLowerCase();
  final tokens = {...account.interests, ...account.expertise}
      .map((item) => item.toLowerCase())
      .toList(growable: false);
  return tokens.any((token) => lowerHaystack.contains(token));
}

String _metadataSafeValue(String value) {
  return value.replaceAll('|', '/').replaceAll(',', '/').trim();
}

List<String> _decodeMetadataList(String raw) {
  if (raw.isEmpty) return const ['Marketing'];
  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<String> _decodeOptionalMetadataList(String raw) {
  if (raw.isEmpty) return const [];
  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<String> availableSchoolNames() {
  final options = <String>{
    'Cal Poly Pomona',
    'Cal State Fullerton',
    'Cal State Long Beach',
    'Cal State Channel Islands',
    'San Diego State University',
    'UC San Diego',
    'UCLA',
    'UC Irvine',
    'UC Berkeley',
    'UC Davis',
    'USC',
    'Loyola Marymount University',
    'Portland State',
    'University of Oregon',
    'Oregon State',
    'Seattle University',
    'University of Washington',
  };

  for (final event in calendarEvents) {
    for (final school in event.nearbyUniversities.split(',')) {
      final trimmed = school.trim();
      if (trimmed.isEmpty) continue;
      options.add(trimmed == 'CPP' ? 'Cal Poly Pomona' : trimmed);
    }
  }

  for (final event in universityFeedEvents) {
    final school = event.university.trim();
    if (school.isNotEmpty) {
      options.add(school);
    }
  }

  final sorted = options.toList(growable: false)..sort();
  return sorted;
}
