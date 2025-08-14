import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'pannable_game.dart';
import 'game_world.dart';
import 'line_component.dart';

void main() {
  runApp(GameWidget(game: RTSGame(world: RTSWorld())));
}

class RTSGame extends PannableGame<RTSWorld> {
  RTSGame({required super.world})
    : super(backgroundColor: Color(0xFF111111), worldSize: Vector2(1000, 1000));
}

class RTSWorld extends World with HasGameReference<RTSGame> {
  // sorted(world1.name, world2.name) -> Component
  Map<String, PositionComponent> connections = {};
  // game world name -> game world component
  Map<String, PositionComponent> gameWorlds = {};

  @override
  Future<void> onLoad() async {
    // --- Worlds ---
    addWorld(
      GameWorld(
        'W1',
        30,
        Vector2(0, 0),
        Colors.purple,
        connectedWorlds: ['W2', 'W3', 'W4'],
      ),
    );
    addWorld(
      GameWorld(
        'W2',
        30,
        Vector2(600, 600),
        Colors.red,
        connectedWorlds: ['W1'],
      ),
    );
    addWorld(
      GameWorld(
        'W3',
        30,
        Vector2(-600, 600),
        Colors.blue,
        connectedWorlds: ['W1'],
      ),
    );
    addWorld(
      GameWorld(
        'W4',
        30,
        Vector2(350, 0),
        Colors.green,
        connectedWorlds: ['W1'],
      ),
    );
    // --- HUD ---
    final text = TextComponent(
      text: 'HUD Element',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
    game.camera.viewport.add(text);
  }

  void addWorld(GameWorld world) {
    final component = CircleComponent(
      radius: world.size,
      paint: Paint()..color = world.color,
      position: world.position,
      priority: 1,
      anchor: Anchor.center,
    );
    gameWorlds[world.name] = component;
    for (final connectedWorldName in world.connectedWorlds) {
      final connection = ([connectedWorldName, world.name]..sort()).toString();
      if (connections.keys.contains(connection)) {
        continue;
      }

      final connectedWorld = gameWorlds[connectedWorldName];
      if (connectedWorld == null) {
        continue;
      }

      final line = LineComponent(
        start: world.position,
        end: connectedWorld.position,
      );
      line.priority = 0;
      connections[connection] = line;
      add(line);
    }
    add(component);
  }

  @override
  void update(double dt) {
    // cannot be less than 0
    // this zooms out
    //
    // use += to zoom in
    // game.camera.viewfinder.zoom -= dt;
    return;
  }
}
