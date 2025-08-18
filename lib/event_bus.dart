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
class EventBus {
  EventBus(this.game);

  final RTSGame game;

  void emit(GameEvent event) {
    if (event is OnWorldTap) {
      _handleWorldTap(event);
      return;
    }
    if (event is OnBackgroundTapped) {
      _handleOnBackgroundTapped();
      return;
    }
    if (event is OnGameTick) {
      _handleGameTick(event);
      return;
    }
    if (event is OnGameStart) {
      _handleGameStart();
      return;
    }
  }

  Future<void> _handleGameStart() async {
    game.world.add(
      await generateBackgroundNoise(
        Size(game.worldSize.x, game.worldSize.y),
        game.dataStore.worldBoundaryPadding,
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
      worldColorOverride: game.dataStore.defaultWorldColor,
    )) {
      _addWorld(world);
    }
    // --- Starting World Settings ---
    game.dataStore.gameWorlds['W1']!.setColor(Colors.green);
    game.dataStore.gameWorlds['W1']!.setMageCount(12);
    game.dataStore.gameWorlds['W2']!.setEvilMageCount(10);

    // --- HUD ---
    game.camera.viewport.add(Hud());

    // --- Set initial camera position ---
    game.camera.viewfinder.position = game.dataStore.gameWorlds['W1']!.position;

    // --- Mage Generator ---
    game.dataStore.mageGenerator = Timer(
      3,
      onTick: () {
        for (final world in game.dataStore.gameWorlds.values) {
          if (world.goodMageCount > 0 && world.evilMageCount == 0) {
            world.incrementMages(1);
          } else if (world.evilMageCount > 0 && world.goodMageCount == 0) {
            world.setEvilMageCount(world.evilMageCount + 1);
          }
        }
      },
      repeat: true,
    );
    game.dataStore.mageGenerator.start();
  }

  void _handleOnBackgroundTapped() {
    game.stopPanning();
  }

  void _handleWorldTap(OnWorldTap event) {
    if (game.dataStore.highlightedWorld == event.worldName) {
      game.dataStore.highlightedWorld = null;
      return;
    }
    if (game.dataStore.highlightedWorld != null) {
      // TODO: animate moving mages
      _moveMage(from: game.dataStore.highlightedWorld!, to: event.worldName);
      game.dataStore.highlightedWorld = null;
      return;
    }
    game.dataStore.highlightedWorld = event.worldName;
    return;
  }

  void _handleGameTick(OnGameTick event) {
    game.dataStore.mageGenerator.update(event.dt);
    return;
  }

  void _moveMage({required String from, required String to}) {
    final fromWorld = game.dataStore.gameWorlds[from]!;
    final toWorld = game.dataStore.gameWorlds[to]!;
    if (fromWorld.connectedWorlds.contains(to) && fromWorld.goodMageCount > 0) {
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
    game.dataStore.gameWorlds[world.name] = component;
    for (final connectedWorldName in world.connectedWorlds) {
      final connection = ([connectedWorldName, world.name]..sort()).toString();
      if (game.dataStore.connections.keys.contains(connection)) {
        continue;
      }

      final connectedWorld = game.dataStore.gameWorlds[connectedWorldName];
      if (connectedWorld == null) {
        continue;
      }

      final line = LineComponent(
        start: world.position,
        end: connectedWorld.position,
      );
      line.priority = 0;
      game.dataStore.connections[connection] = line;
      game.world.add(line);
    }
    game.world.add(component);
  }
}
