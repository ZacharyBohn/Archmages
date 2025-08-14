import 'dart:math';

import 'package:flutter/material.dart' show Offset;
import 'package:flutter_rts/data_classes.dart';
import 'package:uuid/uuid.dart';

(Map<String, World>, List<Connection>) generateMap(Offset screenCenter) {
  Map<String, World> worlds = {};
  List<Connection> connections = [];

  final startingWorld = _generateWorld(screenCenter, minDist: 0, maxDist: 0);
  worlds[startingWorld.id] = startingWorld;

  return (worlds, connections);
}

World _generateWorld(
  Offset from, {
  double minDist = 100,
  double maxDist = 400,
  double minSpacing = 80,
  List<World> existingWorlds = const [],
  int maxWildElementals = 3,
}) {
  final r = Random();
  late Offset newPos;

  bool isValid(Offset pos) {
    for (final w in existingWorlds) {
      if ((pos - w.position).distance < minSpacing) {
        return false;
      }
    }
    return true;
  }

  int attempts = 0;
  do {
    final dist = minDist + r.nextDouble() * (maxDist - minDist);
    final angle = r.nextDouble() * 2 * pi;
    newPos = from + Offset(cos(angle) * dist, sin(angle) * dist);
    attempts++;
  } while (!isValid(newPos) && attempts < 10);

  final wildElementalCount = r.nextInt(maxWildElementals);

  return World(
    id: Uuid().v4(),
    position: newPos,
    type: WorldType.values[r.nextInt(WorldType.values.length)],
    resourceAffinities: {
      ResourceAffinity.water: (r.nextDouble() * 100).roundToDouble() / 100,
      ResourceAffinity.food: (r.nextDouble() * 100).roundToDouble() / 100,
      ResourceAffinity.metal: (r.nextDouble() * 100).roundToDouble() / 100,
      ResourceAffinity.aura: (r.nextDouble() * 100).roundToDouble() / 100,
    },
    elementals: List.generate(
      wildElementalCount,
      (_) => WildElemental(
        type: ElementalType.values[r.nextInt(ElementalType.values.length)],
      ),
    ),
  );
}

// 'W1': World(
    //   id: 'W1',
    //   position: Offset(200, 200),
    //   type: WorldType.verdant,
    //   resourceAffinities: {
    //     'water': 1.0,
    //     'metal': 1.0,
    //     'food': 1.0,
    //     'aura': 1.0,
    //   },
    //   infrastructure: [],
    //   elementals: [WildElemental(type: ElementalType.fire)],
    // ),