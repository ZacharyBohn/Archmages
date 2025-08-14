import 'package:flutter/material.dart';
import 'package:flutter_rts/data_classes.dart';
import 'package:provider/provider.dart';

import 'game_state.dart';

class WorldPopup extends StatelessWidget {
  final String worldID;
  const WorldPopup(this.worldID, {super.key});

  String _getColorName(Color color) {
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.red) return 'Red';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.brown) return 'Brown';
    if (color == Colors.lightGreen) return 'Light Green';
    return 'Unknown';
  }

  String _getWorldTypeName(WorldType type) {
    switch (type) {
      case WorldType.water:
        return 'Water World';
      case WorldType.mining:
        return 'Mining World';
      case WorldType.farming:
        return 'Farming World';
      case WorldType.aura:
        return 'Aura World';
      case WorldType.desert:
        return 'Desert World';
      case WorldType.verdant:
        return 'Verdant World';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final world = state.worlds[worldID];
    if (world == null) {
      return Container();
    }
    // TODO: clean up this UI
    return AlertDialog(
      backgroundColor: Colors.grey[800],
      title: Text(
        'World ${world.id} - ${_getWorldTypeName(world.type)}',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Position: (${world.position.dx.toInt()}, ${world.position.dy.toInt()})',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Color: ${_getColorName(world.color)}',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              'Resource Affinities:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...world.resourceAffinities.entries.map(
              (entry) => Text(
                '  ${entry.key}: ${entry.value}x',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Infrastructure:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (world.infrastructure.isEmpty)
              Text('  None', style: TextStyle(color: Colors.white70))
            else
              ...world.infrastructure.map(
                (infra) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '  ${infra.name} (Level ${infra.level})',
                      style: TextStyle(color: Colors.white70),
                    ),
                    if (infra.level < 5) // Assuming max level is 5
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ElevatedButton(
                          onPressed: () =>
                              state.emit(OnUpgradeInfra(world.id, infra.type)),
                          child: Text('Upgrade'),
                        ),
                      ),
                  ],
                ),
              ),
            SizedBox(height: 10),
            Text(
              'Wild Elementals:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (world.elementals.isEmpty)
              Text('  None', style: TextStyle(color: Colors.white70))
            else
              ...world.elementals.map(
                (elemental) => Text(
                  '  ${elemental.name} (Health: ${elemental.health})',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            SizedBox(height: 10),
            Text(
              'Build New Infrastructure:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: InfrastructureType.values.map((type) {
                // Simple check to prevent building duplicates for now
                if (world.infrastructure.any((infra) => infra.type == type)) {
                  return Container(); // Already built
                }
                return ElevatedButton(
                  onPressed: () => state.emit(OnBuildInfra(world.id, type)),
                  child: Text(Infrastructure(type: type).name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close', style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }
}
