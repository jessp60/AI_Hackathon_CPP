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
}

class SimpleRepository {
  static SimpleState stateFor(AppAccount account) {
    final seed =
        account.uid.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return SimpleState(
      rank: 12,
      level: 4 + (seed % 3),
      totalXp: 900 + (seed % 500),
      currentXpIntoLevel: 240 + (seed % 120),
      xpForNextLevel: 500,
      avatarStage: 'Rising Bronco',
      xpToNextStage: 140,
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
