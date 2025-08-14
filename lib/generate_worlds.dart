import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

import 'game_world.dart';

List<GameWorld> generateWorlds() {
  final worlds = <GameWorld>[];

  worlds.add(
    GameWorld(
      'W1',
      30,
      Vector2(0, 0),
      Colors.purple,
      connectedWorlds: ['W2', 'W3', 'W4'],
    ),
  );

  worlds.add(
    GameWorld('W2', 30, Vector2(600, 600), Colors.red, connectedWorlds: ['W1']),
  );

  worlds.add(
    GameWorld(
      'W3',
      30,
      Vector2(-600, 600),
      Colors.blue,
      connectedWorlds: ['W1'],
    ),
  );

  worlds.add(
    GameWorld('W4', 30, Vector2(350, 0), Colors.green, connectedWorlds: ['W1']),
  );
  return worlds;
}
