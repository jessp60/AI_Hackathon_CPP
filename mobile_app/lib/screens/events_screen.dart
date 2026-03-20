import 'package:flutter/material.dart';

import '../models/app_models.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key, required this.events});

  final List<EventItem> events;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          child: ListTile(
            title: Text(event.name),
            subtitle: Text('${event.dateLabel}\n${event.location}'),
            isThreeLine: true,
            trailing: Text('+${event.xpReward} XP'),
          ),
        );
      },
    );
  }
}
