import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

import 'game_world.dart';

List<GameWorld> generateWorlds({
  required double minDistance,
  required double maxDistance,
  required Vector2 mapSize,
  required int worldCount,
  required int maxConnections,
  double minConnectionAngle = 15.0,
  bool ensureConnected = true,
}) {
  final worlds = <GameWorld>[];
  final random = Random();

  if (worldCount == 0) {
    return worlds;
  }

  int retries = 0;
  const maxRetries = 10000; // To prevent infinite loops

  while (worlds.length < worldCount && retries < maxRetries) {
    final newPosition = Vector2(
      random.nextDouble() * mapSize.x - mapSize.x / 2,
      random.nextDouble() * mapSize.y - mapSize.y / 2,
    );

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
        30, // default radius
        newPosition,
        Colors.primaries[random.nextInt(Colors.primaries.length)],
        connectedWorlds: [],
      );
      worlds.add(newWorld);
      retries = 0; // Reset retries after a successful placement
    } else {
      retries++;
    }
  }

  // Connect worlds
  final minAngleRadians = minConnectionAngle * (pi / 180.0);

  for (final world in worlds) {
    final otherWorlds = worlds
        .where((w) => w != world)
        .map((w) => {'world': w, 'distance': world.position.distanceTo(w.position)})
        .toList();

    otherWorlds.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    for (var i = 0; i < otherWorlds.length; i++) {
      if (world.connectedWorlds.length >= maxConnections) {
        break;
      }

      final neighbor = otherWorlds[i]['world'] as GameWorld;
      final distance = otherWorlds[i]['distance'] as double;

      if (distance > maxDistance) {
        break;
      }

      if (world.connectedWorlds.contains(neighbor.name)) {
        continue;
      }

      final angleToNeighbor = atan2(
        neighbor.position.y - world.position.y,
        neighbor.position.x - world.position.x,
      );

      bool angleIsOk = true;
      for (final connectedNeighborName in world.connectedWorlds) {
        final connectedNeighbor = worlds.firstWhere((w) => w.name == connectedNeighborName);
        final angleToConnectedNeighbor = atan2(
          connectedNeighbor.position.y - world.position.y,
          connectedNeighbor.position.x - world.position.x,
        );

        var angleDiff = (angleToNeighbor - angleToConnectedNeighbor).abs();
        if (angleDiff > pi) {
          angleDiff = 2 * pi - angleDiff;
        }

        if (angleDiff < minAngleRadians) {
          angleIsOk = false;
          break;
        }
      }

      if (angleIsOk) {
        final angleToWorld = atan2(
            world.position.y - neighbor.position.y,
            world.position.x - neighbor.position.x
        );

        bool neighborAngleIsOk = true;
        for (final connectedNeighborName in neighbor.connectedWorlds) {
            final connectedNeighbor = worlds.firstWhere((w) => w.name == connectedNeighborName);
            final angleToConnectedNeighbor = atan2(
                connectedNeighbor.position.y - neighbor.position.y,
                connectedNeighbor.position.x - neighbor.position.x
            );

            var angleDiff = (angleToWorld - angleToConnectedNeighbor).abs();
            if (angleDiff > pi) {
                angleDiff = 2 * pi - angleDiff;
            }

            if (angleDiff < minAngleRadians) {
                neighborAngleIsOk = false;
                break;
            }
        }

        if (neighborAngleIsOk && neighbor.connectedWorlds.length < maxConnections) {
            world.connectedWorlds.add(neighbor.name);
            neighbor.connectedWorlds.add(world.name);
        }
      }
    }
  }

  if (ensureConnected && worlds.isNotEmpty) {
    // 1. Find components
    final components = <List<GameWorld>>[];
    final visited = <GameWorld>{};

    for (final world in worlds) {
      if (!visited.contains(world)) {
        final component = <GameWorld>[];
        final queue = [world];
        visited.add(world);
        component.add(world);

        int head = 0;
        while(head < queue.length) {
          final current = queue[head++];
          for (final neighborName in current.connectedWorlds) {
            final neighbor = worlds.firstWhere((w) => w.name == neighborName);
            if (!visited.contains(neighbor)) {
              visited.add(neighbor);
              component.add(neighbor);
              queue.add(neighbor);
            }
          }
        }
        components.add(component);
      }
    }

    // 2. Connect components if there are more than one
    while (components.length > 1) {
      double minCompDistance = double.infinity;
      List<GameWorld>? componentA;
      List<GameWorld>? componentB;
      GameWorld? worldA;
      GameWorld? worldB;

      // Find the closest two components
      for (int i = 0; i < components.length; i++) {
        for (int j = i + 1; j < components.length; j++) {
          final currentComponentA = components[i];
          final currentComponentB = components[j];
          
          for (final wa in currentComponentA) {
            for (final wb in currentComponentB) {
              final distance = wa.position.distanceTo(wb.position);
              if (distance < minCompDistance) {
                minCompDistance = distance;
                componentA = currentComponentA;
                componentB = currentComponentB;
                worldA = wa;
                worldB = wb;
              }
            }
          }
        }
      }

      if (worldA != null && worldB != null && componentA != null && componentB != null) {
        worldA.connectedWorlds.add(worldB.name);
        worldB.connectedWorlds.add(worldA.name);
        
        // Merge componentB into componentA
        componentA.addAll(componentB);
        components.remove(componentB);
      } else {
        // Should not happen if there are multiple components
        break;
      }
    }
  }

  return worlds;
}