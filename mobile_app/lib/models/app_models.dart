import 'package:firebase_auth/firebase_auth.dart';

class AppAccount {
  const AppAccount({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
  });

  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;

  String get initials {
    final parts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory AppAccount.fromFirebaseUser(User user) {
    final displayName = user.displayName?.trim();
    final emailPrefix = user.email?.split('@').first.trim() ?? 'student';
    return AppAccount(
      uid: user.uid,
      fullName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : emailPrefix.replaceAll(RegExp(r'[._-]+'), ' '),
      email: user.email ?? '',
      photoUrl: user.photoURL?.trim().isEmpty ?? true ? null : user.photoURL,
    );
  }

  AppAccount copyWith({
    String? uid,
    String? fullName,
    String? email,
    Object? photoUrl = _noPhotoUrlOverride,
  }) {
    return AppAccount(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: identical(photoUrl, _noPhotoUrlOverride)
          ? this.photoUrl
          : photoUrl as String?,
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
