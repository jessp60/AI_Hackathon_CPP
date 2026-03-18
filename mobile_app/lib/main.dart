import 'package:flutter/material.dart';

void main() {
  runApp(const InsightQuestApp());
}

class InsightQuestApp extends StatelessWidget {
  const InsightQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insight Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF184E4A),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF184E4A),
          secondary: const Color(0xFFC86F4A),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFFBF8F1),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  final InsightDemoState state = InsightRepository.demoState();

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      CalendarScreen(state: state),
      CitiesScreen(state: state),
      ProfileScreen(state: state),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4E5C2),
              Color(0xFFF7F4EA),
              Color(0xFFE0F0F0),
            ],
          ),
        ),
        child: SafeArea(child: screens[_selectedIndex]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Cities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, required this.state});

  final InsightDemoState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const HeroCard(
          eyebrow: 'Insight Association',
          title: 'Attend events. Level up faster.',
          body: 'Your next unlock comes from real event participation, not grind.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Level',
                value: '${state.studentLevel}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Upcoming',
                value: '${state.events.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final event in state.events) ...[
          EventCard(event: event),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key, required this.state});

  final InsightDemoState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const HeroCard(
          eyebrow: 'Travel Map',
          title: 'Unlock metro regions as you go',
          body: 'City unlocks can come from event check-ins or location-based discovery.',
        ),
        const SizedBox(height: 16),
        for (final region in state.regions) ...[
          RegionCard(region: region),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});

  final InsightDemoState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        HeroCard(
          eyebrow: 'Student Profile',
          title: state.studentName,
          body: 'Marketing explorer on a ${state.attendanceStreak}-event streak.',
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${state.studentLevel}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: state.levelProgress,
                  minHeight: 10,
                ),
                const SizedBox(height: 10),
                Text(
                  '${state.currentXp} XP of ${state.nextLevelXp} XP to the next reward drop',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Badges',
                        value: '${state.badges.length}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Cities',
                        value: '${state.regions.where((r) => r.isUnlocked).length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlocked Badges',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                for (final badge in state.badges) ...[
                  Text('• $badge'),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF3E2B8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF184E4A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final InsightEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${event.date} • ${event.region}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF184E4A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Nearby schools: ${event.nearbyUniversities}'),
            const SizedBox(height: 4),
            Text(
              'Course alignment: ${event.courseAlignment}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                RewardChip(label: '+${event.rewardXp} XP'),
                RewardChip(label: '+${event.rewardCoins} coins'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RegionCard extends StatelessWidget {
  const RegionCard({super.key, required this.region});

  final RegionProgress region;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: region.isUnlocked ? const Color(0xFFE2F0EC) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              region.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              region.isUnlocked
                  ? 'Unlocked • ${region.badgeName}'
                  : 'Locked • Visit or attend a local event to unlock',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF184E4A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text('Featured speaker: ${region.featuredSpeaker}'),
            const SizedBox(height: 4),
            Text(
              region.regionFlavor,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class RewardChip extends StatelessWidget {
  const RewardChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E2B8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF184E4A),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class InsightEvent {
  const InsightEvent({
    required this.title,
    required this.date,
    required this.region,
    required this.nearbyUniversities,
    required this.courseAlignment,
    required this.rewardXp,
    required this.rewardCoins,
  });

  final String title;
  final String date;
  final String region;
  final String nearbyUniversities;
  final String courseAlignment;
  final int rewardXp;
  final int rewardCoins;
}

class RegionProgress {
  const RegionProgress({
    required this.name,
    required this.isUnlocked,
    required this.badgeName,
    required this.featuredSpeaker,
    required this.regionFlavor,
  });

  final String name;
  final bool isUnlocked;
  final String badgeName;
  final String featuredSpeaker;
  final String regionFlavor;
}

class InsightDemoState {
  const InsightDemoState({
    required this.studentName,
    required this.studentLevel,
    required this.currentXp,
    required this.nextLevelXp,
    required this.levelProgress,
    required this.attendanceStreak,
    required this.badges,
    required this.events,
    required this.regions,
  });

  final String studentName;
  final int studentLevel;
  final int currentXp;
  final int nextLevelXp;
  final double levelProgress;
  final int attendanceStreak;
  final List<String> badges;
  final List<InsightEvent> events;
  final List<RegionProgress> regions;
}

class InsightRepository {
  static InsightDemoState demoState() {
    return const InsightDemoState(
      studentName: 'Jordan Rivera',
      studentLevel: 4,
      currentXp: 420,
      nextLevelXp: 600,
      levelProgress: 0.70,
      attendanceStreak: 3,
      badges: [
        'First Check-In',
        'Hackathon Helper',
        'Traveler: San Diego',
        'Traveler: Los Angeles',
      ],
      events: [
        InsightEvent(
          title: 'Insight Portland Student Mixer',
          date: 'Apr 16, 2026',
          region: 'Portland',
          nearbyUniversities: 'Portland State, U of Oregon, Oregon State',
          courseAlignment: 'Marketing Research, Consumer Behavior',
          rewardXp: 120,
          rewardCoins: 35,
        ),
        InsightEvent(
          title: 'Insight San Diego Analytics Night',
          date: 'May 14, 2026',
          region: 'San Diego',
          nearbyUniversities: 'SDSU, USD, UC San Diego',
          courseAlignment: 'Analytics capstones, project presentations',
          rewardXp: 140,
          rewardCoins: 40,
        ),
        InsightEvent(
          title: 'Insight Los Angeles Summer Launch',
          date: 'Jun 18, 2026',
          region: 'Los Angeles',
          nearbyUniversities: 'UCLA, USC, Cal Poly Pomona, LMU',
          courseAlignment: 'Summer intensives, boot camps',
          rewardXp: 180,
          rewardCoins: 50,
        ),
        InsightEvent(
          title: 'Insight Bay Area Innovation Session',
          date: 'Jul 23, 2026',
          region: 'San Francisco',
          nearbyUniversities: 'USF, SFSU, Berkeley Haas, Santa Clara',
          courseAlignment: 'Executive education, certificate programs',
          rewardXp: 160,
          rewardCoins: 45,
        ),
        InsightEvent(
          title: 'Insight Seattle Welcome Week',
          date: 'Aug 20, 2026',
          region: 'Seattle',
          nearbyUniversities: 'UW Foster, Seattle U, WSU',
          courseAlignment: 'New student orientations, welcome week',
          rewardXp: 125,
          rewardCoins: 35,
        ),
      ],
      regions: [
        RegionProgress(
          name: 'Los Angeles',
          isUnlocked: true,
          badgeName: 'Metro Connector',
          featuredSpeaker: 'Donna Flynn',
          regionFlavor:
              'A strong hub for research operations, brand storytelling, and student networking.',
        ),
        RegionProgress(
          name: 'San Diego',
          isUnlocked: true,
          badgeName: 'Coastal Analyst',
          featuredSpeaker: 'Monica Voss',
          regionFlavor:
              'A city focused on platform insights, client success, and data-driven storytelling.',
        ),
        RegionProgress(
          name: 'Portland',
          isUnlocked: false,
          badgeName: 'Northwest Strategist',
          featuredSpeaker: 'Katie Nelson',
          regionFlavor:
              'A region shaped by brand strategy, optimization, and member engagement.',
        ),
        RegionProgress(
          name: 'San Francisco',
          isUnlocked: false,
          badgeName: 'Innovation Scout',
          featuredSpeaker: 'Katrina Noelle',
          regionFlavor:
              'A destination for qualitative research, analytics, and insight-led decision making.',
        ),
        RegionProgress(
          name: 'Seattle',
          isUnlocked: false,
          badgeName: 'Research Trailblazer',
          featuredSpeaker: 'Greg Carter',
          regionFlavor:
              'A practical research community with strength in focus groups and interviews.',
        ),
        RegionProgress(
          name: 'Ventura / Thousand Oaks',
          isUnlocked: false,
          badgeName: 'Community Builder',
          featuredSpeaker: 'Travis Miller',
          regionFlavor:
              'A relationship-driven region blending innovation, sales, and customer experience.',
        ),
        RegionProgress(
          name: 'Orange County / Long Beach',
          isUnlocked: false,
          badgeName: 'Signal Seeker',
          featuredSpeaker: 'Rob Kaiser',
          regionFlavor:
              'A creative analytics corridor with room for marketing science and growth.',
        ),
      ],
    );
  }
}
