import 'package:firebase_auth/firebase_auth.dart';

enum AppAccountType { student, faculty }

class AppAccount {
  const AppAccount({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.accountType,
    this.photoUrl,
    this.facultyPosition,
    this.isFacultyVerified = false,
  });

  final String uid;
  final String fullName;
  final String email;
  final AppAccountType accountType;
  final String? photoUrl;
  final String? facultyPosition;
  final bool isFacultyVerified;

  bool get isFaculty => accountType == AppAccountType.faculty;
  bool get isStudent => accountType == AppAccountType.student;

  String get memberLabel {
    if (isFaculty) return 'Faculty';
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
      photoUrl: user.photoURL?.trim().isEmpty ?? true ? null : user.photoURL,
      facultyPosition: parsed.facultyPosition,
      isFacultyVerified: parsed.isFacultyVerified,
    );
  }

  static String encodeDisplayName({
    required String fullName,
    required AppAccountType accountType,
    String? facultyPosition,
    bool isFacultyVerified = false,
  }) {
    final safeName = fullName.trim().isEmpty ? 'BroncoBoost Member' : fullName.trim();
    final safePosition = (facultyPosition ?? '').replaceAll('|', '/').trim();
    final accountTypeLabel = accountType == AppAccountType.faculty ? 'faculty' : 'student';
    final verifiedLabel = isFacultyVerified ? 'verified' : 'pending';
    return '$safeName [[bb|$accountTypeLabel|$safePosition|$verifiedLabel]]';
  }

  AppAccount copyWith({
    String? uid,
    String? fullName,
    String? email,
    AppAccountType? accountType,
    Object? photoUrl = _noPhotoUrlOverride,
    Object? facultyPosition = _noPhotoUrlOverride,
    bool? isFacultyVerified,
  }) {
    return AppAccount(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      accountType: accountType ?? this.accountType,
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
      events: const [
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
      cities: const [
        CityUnlock(name: 'Pomona', unlocked: true),
        CityUnlock(name: 'Los Angeles', unlocked: true),
        CityUnlock(name: 'San Diego', unlocked: false),
        CityUnlock(name: 'San Francisco', unlocked: false),
      ],
    );
  }
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
    this.facultyPosition,
    required this.isFacultyVerified,
  });

  final String fullName;
  final AppAccountType accountType;
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

  return _ParsedAccountProfile(
    fullName: fullName.isNotEmpty
        ? fullName
        : (fallbackEmail.split('@').first.trim().isNotEmpty
            ? fallbackEmail.split('@').first.trim()
            : fallbackUid),
    accountType: typeToken == 'faculty'
        ? AppAccountType.faculty
        : AppAccountType.student,
    facultyPosition: positionToken.isEmpty ? null : positionToken,
    isFacultyVerified: verifiedToken == 'verified',
  );
}
