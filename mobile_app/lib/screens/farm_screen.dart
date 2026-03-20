import 'package:flutter/material.dart';

import '../models/app_models.dart';

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key, required this.state});

  final SimpleState state;

  @override
  Widget build(BuildContext context) {
    final harvestProgress = state.levelProgress.clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your farm', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Grow your Bronco farm by checking in, earning XP, and unlocking new stages.',
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: harvestProgress),
                const SizedBox(height: 10),
                Text(
                  '${state.currentXpIntoLevel}/${state.xpForNextLevel} XP toward the next harvest',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.agriculture_outlined),
            title: const Text('Current growth stage'),
            subtitle: Text(state.avatarStage),
            trailing: Text('${state.xpToNextStage} XP left'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.local_florist_outlined),
            title: const Text('Unlocked plots'),
            trailing:
                Text('${state.cities.where((city) => city.unlocked).length}'),
          ),
        ),
        const SizedBox(height: 20),
        Text('Farm boosts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...state.events.take(3).map(
          (event) => Card(
            child: ListTile(
              leading: const Icon(Icons.eco_outlined),
              title: Text(event.name),
              subtitle: const Text('Attend this event to help your farm grow'),
              trailing: Text('+${event.xpReward}'),
            ),
          ),
        ),
      ],
    );
  }
}
