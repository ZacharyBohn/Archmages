import 'dart:math' show max, min;

import 'package:archmage_rts/drag_line_component.dart';
import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'background_noise.dart';
import 'data_store.dart';
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
    }
    if (event is OnGameTick) {
      _handleGameTick(event);
    }
    if (event is OnGameStart) {
      _handleGameStart();
    }
    if (event is OnEvilMageAITick) {
      _handleEvilMageAI();
    }
    if (event is OnWorldChangedAliance) {
      _handleWorldChangeAliance(event);
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
    }
    if (event is OnCreateMoveCommand) {
      _handleMoveCommand(event);
    }
    if (event is OnForwardCommandProcessTick) {
      _handleOnForwardCommandProcessTick(event);
    }
  }

  void _cancelMoveCommand(String connectionName) {
    final moveCommand = game.dataStore.moveCommandTimers[connectionName];
    if (moveCommand != null) {
      moveCommand.timer.stop();
      game.dataStore.moveCommandTimers.remove(connectionName);
      final connection = game.dataStore.connections[connectionName];
      if (connection != null) {
        connection.paint.color = const Color(0xFFBBBBBB);
      }
    }
  }

  void _handleMoveCommand(OnCreateMoveCommand event) {
    // TODO: move commands are direction-agnostic.
    // A move command from A to B can be cancelled by a command from B to A.
    // This can be a problem if both worlds are good-aligned.
    final connectionName = ([event.from, event.to]..sort()).toString();

    if (game.dataStore.moveCommandTimers.containsKey(connectionName)) {
      _cancelMoveCommand(connectionName);
      return;
    }

    // Create a new command
    final timer = Timer(
      3,
      onTick: () {
        emit(OnForwardCommandProcessTick(event.from, event.to));
      },
      repeat: true,
      autoStart: true,
    );
    game.dataStore.moveCommandTimers[connectionName] = MoveCommand(
      timer,
      event.from,
      event.to,
    );
    final mageCount =
        game.dataStore.gameWorlds[event.from]!.gameWorld.mageCount;
    _moveMage(
      from: event.from,
      to: event.to,
      amountToMove: (mageCount / 10).ceil(),
    );

    final connection = game.dataStore.connections[connectionName];
    if (connection != null) {
      connection.paint.color = Colors.green;
    }
  }

  void _handleOnForwardCommandProcessTick(OnForwardCommandProcessTick event) {
    final mageCount =
        game.dataStore.gameWorlds[event.from]!.gameWorld.mageCount;
    final amountOver36 = max(0, mageCount - 36);
    int finalAmountToMove = max(0, (mageCount / 4).ceil()) + amountOver36;
    finalAmountToMove = min(finalAmountToMove, mageCount - 1);
    if (mageCount > 2 && finalAmountToMove > 0) {
      _moveMage(
        from: event.from,
        to: event.to,
        amountToMove: finalAmountToMove,
      );
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
      worldCount: 18,
      maxDistance: 700.0,
      maxConnections: 5,
      worldSize: game.dataStore.worldRadius,
      worldColorOverride: game.dataStore.defaultWorldColor,
    )) {
      _addWorld(world);
    }
    // --- Starting World Settings ---
    game.dataStore.gameWorlds['W1']!.gameWorld.addMages(
      count: 14,
      incomingFaction: Faction.good,
    );
    game.dataStore.gameWorlds['W2']!.gameWorld.addMages(
      count: 10,
      incomingFaction: Faction.evil,
    );

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
      if (world.gameWorld.mageCount > 0 &&
          world.gameWorld.faction != Faction.neutral &&
          world.gameWorld.mageCount < game.dataStore.maxWorldPopulation) {
        world.gameWorld.addMages(
          count: 1,
          incomingFaction: world.gameWorld.faction,
        );
      }
    }
  }

  void _handleOnBackgroundTapped() {
    game.stopPanning();
  }

  void _handleCanvasDrag(OnCanvasDrag event) {
    if (game.dataStore.tappedDownWorld == null) {
      game.pan(event.delta);
    } else if (game.dataStore.dragLine == null &&
        game.dataStore.tappedDownWorld?.gameWorld.faction == Faction.good) {
      final fromWorldPosition = game.dataStore.tappedDownWorld!.position;
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
    if (game.dataStore.tappedDownWorld?.gameWorld.faction == Faction.good) {
      final toWorldName = game.world
          .componentsAtPoint(game.dataStore.dragLine!.end)
          .whereType<GameWorldComponent>()
          .firstOrNull
          ?.gameWorld
          .name;
      if (toWorldName != null) {
        emit(
          OnCreateMoveCommand(
            from: game.dataStore.tappedDownWorld!.gameWorld.name,
            to: toWorldName,
          ),
        );
      }
    }
    if (game.dataStore.dragLine != null) {
      game.world.remove(game.dataStore.dragLine!);
    }
    game.dataStore.dragLine = null;
    game.dataStore.tappedDownWorld = null;
  }

  void _handleWorldTapDown(OnWorldTapDown event) {
    game.dataStore.tappedDownWorld = game.dataStore.gameWorlds[event.worldName];
  }

  void _handleGameTick(OnGameTick event) {
    if (!game.dataStore.setupComplete) {
      return;
    }
    game.dataStore.mageGenerator.update(event.dt);
    game.dataStore.evilMageAI.update(event.dt);
    for (final timer in game.dataStore.moveCommandTimers.values) {
      timer.timer.update(event.dt);
    }
  }

  void _handleEvilMageAI() {
    for (final world in game.dataStore.gameWorlds.values) {
      if (world.gameWorld.faction == Faction.evil &&
          world.gameWorld.mageCount > 1) {
        final possibleTargets = world.gameWorld.connectedWorlds.where((
          worldName,
        ) {
          final connectedWorld = game.dataStore.gameWorlds[worldName]!;
          final isOpposingFaction =
              connectedWorld.gameWorld.faction != Faction.evil;
          final hasLowMages =
              connectedWorld.gameWorld.mageCount <
              (world.gameWorld.mageCount / 1.5);
          return isOpposingFaction || hasLowMages;
        }).toList();

        if (possibleTargets.isNotEmpty) {
          final targetWorldName = possibleTargets.reduce((a, b) {
            final worldA = game.dataStore.gameWorlds[a]!.gameWorld;
            final worldB = game.dataStore.gameWorlds[b]!.gameWorld;
            if (worldA.faction == Faction.good &&
                worldB.faction != Faction.good) {
              return a;
            }
            if (worldA.faction != Faction.good &&
                worldB.faction == Faction.good) {
              return b;
            }
            return worldA.mageCount < worldB.mageCount ? a : b;
          });
          final targetWorld =
              game.dataStore.gameWorlds[targetWorldName]?.gameWorld;
          if (targetWorld != null &&
              targetWorld.faction == Faction.evil &&
              targetWorld.mageCount >= 40) {
            return;
          }
          final amountOver36 = max(0, world.gameWorld.mageCount - 36);
          final finalAmountToMove = min(
            (world.gameWorld.mageCount / 2).ceil() + amountOver36,
            10,
          );
          _moveMage(
            from: world.gameWorld.name,
            to: targetWorldName,
            amountToMove: finalAmountToMove,
          );
        }
      }
    }
  }

  void _moveMage({
    required String from,
    required String to,
    int amountToMove = 1,
  }) {
    final fromWorld = game.dataStore.gameWorlds[from]!;
    final toWorld = game.dataStore.gameWorlds[to]!;
    if (fromWorld.gameWorld.connectedWorlds.contains(to) &&
        fromWorld.gameWorld.mageCount > 0) {
      amountToMove = min(fromWorld.gameWorld.mageCount, amountToMove);
      final faction = fromWorld.gameWorld.faction;
      fromWorld.gameWorld.removeMages(count: amountToMove);

      final mage = MageComponent(
        number: amountToMove,
        size: Vector2.all(30),
        isEvil: faction == Faction.evil,
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
            toWorld.gameWorld.addMages(
              count: amountToMove,
              incomingFaction: faction,
            );
            mage.removeFromParent();
          },
        ),
      );
      game.world.add(mage);
    }
  }

  void _handleWorldChangeAliance(OnWorldChangedAliance event) {
    game.dataStore.goodWorldCount = game.dataStore.gameWorlds.values
        .where((world) => world.gameWorld.faction == Faction.good)
        .length;
    game.dataStore.evilWorldCount = game.dataStore.gameWorlds.values
        .where((world) => world.gameWorld.faction == Faction.evil)
        .length;

    if (event.newFaction != Faction.good) {
      final moveCommandsToCancel = <String>[];
      for (final entry in game.dataStore.moveCommandTimers.entries) {
        if (entry.value.from == event.worldName) {
          moveCommandsToCancel.add(entry.key);
        }
      }
      for (final key in moveCommandsToCancel) {
        _cancelMoveCommand(key);
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
