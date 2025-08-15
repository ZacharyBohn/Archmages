import 'dart:collection';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, debugPrint;

import 'game_world.dart';

List<GameWorld> generateWorlds({
  required double minDistance,
  required double maxDistance,
  required Vector2 mapSize,
  required int worldCount,
  required int maxConnections,
}) {
  final worlds = <GameWorld>[];
  final random = Random();

  if (worldCount == 0) {
    return worlds;
  }

  final rootWorld = GameWorld(
    'W1',
    30,
    Vector2(0, 0),
    Colors.purple,
    connectedWorlds: [],
  );
  worlds.add(rootWorld);

  var currentLevel = Queue<GameWorld>.from([rootWorld]);

  while (worlds.length < worldCount) {
    var nextLevel = Queue<GameWorld>();
    for (final parentWorld in currentLevel) {
      if (worlds.length >= worldCount) break;

      // Each parent tries to spawn some children
      int childrenToSpawn = random.nextInt(maxConnections) + 1;
      for (int j = 0; j < childrenToSpawn; j++) {
        if (worlds.length >= worldCount) break;

        bool worldPlaced = false;
        int retries = 0;
        while (!worldPlaced) {
          retries++;
          if (retries > currentLevel.length) {
            // Failed to place this child
            break;
          }

          final angle =
              atan2(parentWorld.position.y, parentWorld.position.x) +
              (random.nextDouble() - 0.5) * (pi / 1.5);
          final distance =
              minDistance + random.nextDouble() * (maxDistance - minDistance);
          final newPosition =
              parentWorld.position + Vector2(cos(angle), sin(angle)) * distance;

          bool tooClose = false;
          for (final world in worlds) {
            if (world.position.distanceTo(newPosition) < minDistance) {
              tooClose = true;
              break;
            }
          }

          if (!tooClose) {
            final newWorld = GameWorld(
              'W${worlds.length + 1}',
              30,
              newPosition,
              Colors.primaries[random.nextInt(Colors.primaries.length)],
              connectedWorlds: [],
            );

            newWorld.connectedWorlds.add(parentWorld.name);
            parentWorld.connectedWorlds.add(newWorld.name);

            worlds.add(newWorld);
            nextLevel.add(newWorld);
            worldPlaced = true;
          }
        }
      }
    }

    if (nextLevel.isEmpty) {
      debugPrint(
        'Could not place any more worlds. Generated ${worlds.length}/$worldCount',
      );
      break; // Stop if we can't expand further
    }
    currentLevel = nextLevel;
  }

  return worlds;
}
