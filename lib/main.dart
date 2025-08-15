import 'package:archmage_rts/background_noise.dart';
import 'package:archmage_rts/game_world_component.dart';
import 'package:archmage_rts/world_boundary.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:archmage_rts/pannable_game.dart';
import 'game_world.dart';
import 'generate_worlds.dart';
import 'hud.dart';
import 'line_component.dart';

void main() {
  runApp(GameWidget(game: RTSGame(world: RTSWorld())));
}

class RTSGame extends PannableGame<RTSWorld> {
  RTSGame({required super.world})
    : super(backgroundColor: Color(0xFF111111), worldSize: Vector2(5000, 5000));
}

class RTSWorld extends World with HasGameReference<RTSGame> {
  // sorted(world1.name, world2.name) -> Component
  Map<String, PositionComponent> connections = {};
  // game world name -> game world component
  Map<String, PositionComponent> gameWorlds = {};

  final worldBoundaryPadding = 100.0;

  @override
  Future<void> onLoad() async {
    add(
      await generateBackgroundNoise(
        Size(game.worldSize.x, game.worldSize.y),
        worldBoundaryPadding,
      ),
    );
    // --- Worlds ---
    for (final world in generateWorlds(
      minDistance: 150.0,
      mapSize: game.worldSize,
      worldCount: 80,
      maxDistance: 350.0,
      maxConnections: 4,
    )) {
      addWorld(world);
    }

    // --- Draw World Boundaries
    add(WorldBoundary(game.worldSize, worldBoundaryPadding));

    // --- HUD ---
    game.camera.viewport.add(Hud());
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

  /// Adds the game world to the FlameWorld
  /// And draws any connections. Connections are guarenteed
  /// to be drawn only once.
  void addWorld(GameWorld world) {
    final component = GameWorldComponent.from(world);
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
}
