import 'package:flutter/material.dart';

import '../models/app_models.dart';

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key, required this.cities});

  final List<CityUnlock> cities;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return Card(
          child: ListTile(
            leading:
                Icon(city.unlocked ? Icons.check_circle : Icons.lock_outline),
            title: Text(city.name),
            subtitle: Text(
              city.unlocked ? 'Unlocked' : 'Travel here to unlock this city',
            ),
          ),
        );
      },
    );
  }
}
