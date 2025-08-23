import 'package:archmage_rts/drag_line_component.dart';
import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'background_noise.dart';
import 'factions.dart';
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

  /// Receive all incoming events through here
  void emit(GameEvent event) {
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
    if (event is OnEvilMageAITick) {
      _handleEvilMageAI();
      return;
    }
    if (event is OnWorldChangedAliance) {
      _handleWorldChangeAliance(event);
      return;
    }
    if (event is OnZoomChanged) {
      _handleZoomChange(event);
    }
    if (event is OnCanvasDrag) {
      _handleCanvasDrag(event);
    }
    if (event is OnCanvasDragEnd) {
      _handleCanvasDragEnd();
    }
    if (event is OnWorldTapDown) {
      _handleWorldTapDown(event);
      return;
    }
    if (event is OnCreateMoveCommand) {
      _handleMoveCommand(event);
    }
  }

  void _handleMoveCommand(OnCreateMoveCommand event) {
    final connectionName = ([event.from, event.to]..sort()).toString();
    final connection =
        game.dataStore.connections[connectionName] as LineComponent?;

    if (game.dataStore.moveCommandsMapping.containsKey(event.to) &&
        game.dataStore.moveCommandsMapping[event.to] == event.from) {
      game.dataStore.moveCommandsMapping.remove(event.to);
      game.dataStore.moveCommandTimers['${event.to}.${event.from}']?.stop();
      game.dataStore.moveCommandTimers.remove('${event.to}.${event.from}');
      if (connection != null) {
        connection.paint.color = const Color(0xFFBBBBBB);
      }
    } else {
      game.dataStore.moveCommandsMapping[event.from] = event.to;
      final timer = Timer(
        3,
        onTick: () {
          // TODO: make this less buggy. GameWorldComponent should use
          // a state machine. Right now it's getting out of sync.
          // TODO: make this emit an event
          // TODO: make it take into account the size of the world?
          // TODO: take into account overflow?
          if (game.dataStore.gameWorlds[event.from]!.mageCount > 2) {
            _moveMage(from: event.from, to: event.to);
          }
        },
        repeat: true,
        autoStart: true,
      );
      game.dataStore.moveCommandTimers['${event.from}.${event.to}'] = timer;
      _moveMage(from: event.from, to: event.to);
      if (connection != null) {
        connection.paint.color = Colors.green;
      }
    }
  }

  void _handleZoomChange(OnZoomChanged event) {
    if (event.value <= 1.0) {
      final maxScale =
          game.dataStore.minDistanceBetweenWorlds /
          (2 * game.dataStore.worldRadius);
      final newScale = (1.0 / event.value).clamp(1.0, maxScale);
      game.dataStore.componentScale = newScale;
    } else {
      game.dataStore.componentScale = 1.0;
    }
  }

  Future<void> _handleGameStart() async {
    game.world.add(
      await generateBackgroundNoise(
        Size(game.worldSize.x * 2, game.worldSize.y * 2),
        game.dataStore.worldBoundaryPadding,
        opacity: 0.1,
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
      minDistance: game.dataStore.minDistanceBetweenWorlds,
      mapSize: game.worldSize,
      worldCount: 80,
      maxDistance: 700.0,
      maxConnections: 6,
      worldSize: game.dataStore.worldRadius,
      worldColorOverride: game.dataStore.defaultWorldColor,
    )) {
      _addWorld(world);
    }
    // --- Starting World Settings ---
    game.dataStore.gameWorlds['W1']!.setMageCount(12, Faction.good);
    game.dataStore.gameWorlds['W2']!.setMageCount(10, Faction.evil);

    // --- HUD ---
    game.camera.viewport.add(Hud());

    // --- Set initial camera position ---
    game.camera.viewfinder.position = game.dataStore.gameWorlds['W1']!.position;

    // --- Mage Generator ---
    game.dataStore.mageGenerator = Timer(
      3,
      onTick: _handleMageGeneratorTick,
      repeat: true,
    );
    game.dataStore.mageGenerator.start();

    game.dataStore.evilMageAI = Timer(
      2,
      onTick: () {
        emit(OnEvilMageAITick());
      },
      repeat: true,
      autoStart: true,
    );
    game.dataStore.setupComplete = true;
  }

  void _handleMageGeneratorTick() {
    for (final world in game.dataStore.gameWorlds.values) {
      if (world.mageCount > 0 &&
          world.gameWorld.faction != Faction.neutral &&
          world.mageCount < game.dataStore.maxWorldPopulation) {
        world.incrementMages(1, world.gameWorld.faction);
      }
    }
  }

  void _handleOnBackgroundTapped() {
    game.stopPanning();
  }

  void _handleCanvasDrag(OnCanvasDrag event) {
    if (game.dataStore.dragFromWorld == null) {
      game.pan(event.delta);
    } else if (game.dataStore.dragLine == null) {
      final fromWorldPosition = game.dataStore.dragFromWorld!.position;
      game.dataStore.dragLine = DragLineComponent(
        origin: fromWorldPosition,
        end: fromWorldPosition,
      );
      game.world.add(game.dataStore.dragLine!);
    } else {
      game.dataStore.dragLine?.end += event.delta;
    }
  }

  void _handleCanvasDragEnd() {
    if (game.dataStore.dragLine != null) {
      final toWorldName = game.world
          .componentsAtPoint(game.dataStore.dragLine!.end)
          .whereType<GameWorldComponent>()
          .firstOrNull
          ?.name;
      if (toWorldName != null) {
        emit(
          OnCreateMoveCommand(
            from: game.dataStore.dragFromWorld!.name,
            to: toWorldName,
          ),
        );
      }
      game.world.remove(game.dataStore.dragLine!);
    }
    game.dataStore.dragLine = null;
    game.dataStore.dragFromWorld = null;
  }

  void _handleWorldTapDown(OnWorldTapDown event) {
    game.dataStore.dragFromWorld = game.dataStore.gameWorlds[event.worldName];
  }

  void _handleGameTick(OnGameTick event) {
    if (!game.dataStore.setupComplete) {
      return;
    }
    game.dataStore.mageGenerator.update(event.dt);
    game.dataStore.evilMageAI.update(event.dt);
    for (final timer in game.dataStore.moveCommandTimers.values) {
      timer.update(event.dt);
    }
  }

  void _handleEvilMageAI() {
    for (final world in game.dataStore.gameWorlds.values) {
      if (world.gameWorld.faction == Faction.evil && world.mageCount > 1) {
        // 50% chance to send an evil mage
        if (game.random.nextDouble() < 0.5) {
          final possibleTargets = world.connectedWorlds.where((worldName) {
            final connectedWorld = game.dataStore.gameWorlds[worldName]!;
            return connectedWorld.gameWorld.faction != Faction.evil;
          }).toList();

          if (possibleTargets.isNotEmpty) {
            // Pick a random non-evil adjacent world
            final targetWorldName =
                possibleTargets[game.random.nextInt(possibleTargets.length)];
            _moveMage(from: world.name, to: targetWorldName);
          }
        }
      }
    }
  }

  void _moveMage({required String from, required String to}) {
    final fromWorld = game.dataStore.gameWorlds[from]!;
    final toWorld = game.dataStore.gameWorlds[to]!;
    if (fromWorld.connectedWorlds.contains(to) && fromWorld.mageCount > 0) {
      final amountToMove = 1;
      final count = fromWorld.decrementMages(amountToMove);
      if (count > 0) {
        final mage = MageComponent(
          number: count,
          size: Vector2.all(30),
          isEvil: fromWorld.gameWorld.faction == Faction.evil,
        );
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
              toWorld.incrementMages(count, fromWorld.gameWorld.faction);
              mage.removeFromParent();
            },
          ),
        );
        game.world.add(mage);
      }
    }
  }

  void _handleWorldChangeAliance(OnWorldChangedAliance event) {
    game.dataStore.goodWorldCount = game.dataStore.gameWorlds.values
        .where((world) => world.gameWorld.faction == Faction.good)
        .length;
    game.dataStore.evilWorldCount = game.dataStore.gameWorlds.values
        .where((world) => world.gameWorld.faction == Faction.evil)
        .length;
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
