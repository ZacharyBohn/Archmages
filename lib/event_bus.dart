import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'background_noise.dart';
import 'game_events.dart';
import 'game_world.dart';
import 'game_world_component.dart';
import 'generate_worlds.dart';
import 'hud.dart';
import 'line_component.dart';
import 'mage_component.dart';
import 'tap_area.dart';

/// Accepts all events and handles them.
/// Basically this is the core for all game logic
/// besides what is able to be handled in-component.
///
/// This also serves as the game's data store.
class EventBus {
  EventBus(this.game);
  // game world name -> game world component
  Map<String, GameWorldComponent> gameWorlds = {};
  // sorted(world1.name, world2.name) -> Component
  Map<String, PositionComponent> connections = {};
  Set<MageComponent> travelingMages = {};

  String? highlightedWorld;

  final RTSGame game;

  // Only gonna be used temporarily =0
  late final Timer mageGenerator;

  final worldBoundaryPadding = 300.0;

  void emit(GameEvent event) {
    // TODO: move to handler
    if (event is OnWorldTap) {
      if (highlightedWorld == event.worldName) {
        highlightedWorld = null;
        return;
      }
      if (highlightedWorld != null) {
        // TODO: animate moving mages
        _moveMage(from: highlightedWorld!, to: event.worldName);
        highlightedWorld = null;
        return;
      }
      highlightedWorld = event.worldName;
      return;
    }
    // TODO: move to handler
    if (event is OnBackgroundTapped) {
      game.stopPanning();
      return;
    }
    if (event is OnGameTick) {
      _handleGameTick(event);
    }
    if (event is OnGameStart) {
      _handleGameStart();
    }
    return;
  }

  Future<void> _handleGameStart() async {
    game.world.add(
      await generateBackgroundNoise(
        Size(game.worldSize.x, game.worldSize.y),
        worldBoundaryPadding,
      ),
    );
    game.world.add(
      TapArea(
        position: -(game.worldSize / 2),
        size: game.worldSize,
        callback: () => emit(OnBackgroundTapped()),
      ),
    );
    // --- Worlds ---
    for (final world in generateWorlds(
      minDistance: 150.0,
      mapSize: game.worldSize,
      worldCount: 80,
      maxDistance: 700.0,
      maxConnections: 6,
      worldSize: 45.0,
      worldColorOverride: Color(0xFF505050),
    )) {
      _addWorld(world);
    }
    // --- Starting World Settings ---
    gameWorlds['W1']!.setColor(Colors.green);
    gameWorlds['W1']!.setMageCount(12);

    // --- HUD ---
    game.camera.viewport.add(Hud());

    // --- Set initial camera position ---
    game.camera.viewfinder.position = gameWorlds['W1']!.position;

    // --- Mage Generator ---
    mageGenerator = Timer(
      3,
      onTick: () {
        gameWorlds['W1']?.incrementMages(1);
      },
      repeat: true,
    );
    mageGenerator.start();
    return;
  }

  void _handleGameTick(OnGameTick event) {
    mageGenerator.update(event.dt);
    return;
  }

  void _moveMage({required String from, required String to}) {
    final fromWorld = gameWorlds[from]!;
    final toWorld = gameWorlds[to]!;
    if (fromWorld.connectedWorlds.contains(to) && fromWorld.mageCount > 0) {
      final count = fromWorld.decrementMages();
      if (count > 0) {
        final mage = MageComponent(number: count, size: Vector2.all(20));
        mage.anchor = Anchor.center;

        final direction = (toWorld.position - fromWorld.position).normalized();

        final startPosition = fromWorld.position + direction * fromWorld.radius;
        final endPosition = toWorld.position - direction * toWorld.radius;

        mage.position = startPosition;
        mage.add(
          MoveToEffect(
            endPosition,
            EffectController(speed: 150),
            onComplete: () {
              toWorld.incrementMages(count);
              mage.removeFromParent();
            },
          ),
        );
        game.world.add(mage);
      }
    }
  }

  void _addWorld(GameWorld world) {
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
      game.world.add(line);
    }
    game.world.add(component);
  }
}
