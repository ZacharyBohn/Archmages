import 'package:archmage_rts/game_events.dart';
import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'factions.dart';
import 'game_world.dart';

class GameWorldComponent extends CircleComponent
    with TapCallbacks, HasGameReference<RTSGame> {
  GameWorldComponent({
    required this.gameWorld,
    super.position,
    super.priority = 1,
    super.anchor = Anchor.center,
  }) : super(radius: gameWorld.size, paint: Paint()..color = gameWorld.color);

  static GameWorldComponent from(GameWorld gameWorld) {
    return GameWorldComponent(
      gameWorld: gameWorld,
      position: gameWorld.position,
    );
  }

  GameWorld gameWorld;
  TextComponent? mageCountLabel;

  String get name => gameWorld.name;

  List<String> get connectedWorlds => gameWorld.connectedWorlds;

  int get mageCount => gameWorld.mageCount;

  void setMageCount(int count, Faction faction) {
    gameWorld.mageCount = count;
    _updateWorldColorAndAlliance(faction);
  }

  int decrementMages([int count = 1]) {
    if (gameWorld.mageCount > 0) {
      final actualCount = min(count, gameWorld.mageCount);
      gameWorld.mageCount -= actualCount;
      if (gameWorld.mageCount == 0) {
        _updateWorldColorAndAlliance(Faction.neutral);
      }
      return actualCount;
    }
    return 0;
  }

  void incrementMages(int count, Faction faction) {
    if (count == 0) {
      return;
    }

    if (faction == gameWorld.faction) {
      gameWorld.mageCount += count;
    } else {
      if (count > gameWorld.mageCount) {
        _updateWorldColorAndAlliance(faction);
        gameWorld.mageCount = count - gameWorld.mageCount;
        gameWorld.faction = faction;
      } else {
        gameWorld.mageCount -= count;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isMounted) {
      return;
    }
    scale = Vector2.all(game.dataStore.componentScale);
    _updateMageCounter();
  }

  void _updateWorldColorAndAlliance(Faction newFaction) {
    final oldFaction = gameWorld.faction;
    if (oldFaction == newFaction) {
      return;
    }
    if (newFaction == Faction.evil) {
      setColor(Colors.red);
      newFaction = Faction.evil;
    } else if (newFaction == Faction.good) {
      setColor(Colors.green);
      newFaction = Faction.good;
    } else if (newFaction == Faction.neutral) {
      setColor(game.dataStore.defaultWorldColor);
      newFaction = Faction.neutral;
    }
    game.eventBus.emit(
      OnWorldChangedAliance(oldFaction: oldFaction, newFaction: newFaction),
    );
    gameWorld.faction = newFaction;
  }

  _updateMageCounter() {
    if (gameWorld.mageCount > 0 && mageCountLabel != null) {
      mageCountLabel!.text = gameWorld.mageCount.toString();
    }
    if (gameWorld.mageCount > 0 && mageCountLabel == null) {
      mageCountLabel = TextComponent(
        text: gameWorld.mageCount.toString(),
        position: size / 2,
        anchor: Anchor.center,
        textRenderer: TextPaint(style: TextStyle(color: Colors.white)),
      );
      add(mageCountLabel!);
    }
    if (gameWorld.mageCount == 0 && mageCountLabel != null) {
      remove(mageCountLabel!);
      mageCountLabel = null;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.eventBus.emit(OnWorldTapDown(gameWorld.name));
    super.onTapDown(event);
  }

  @override
  void setColor(Color color, {Object? paintId}) {
    gameWorld.color = color;
    super.setColor(color, paintId: paintId);
  }
}
