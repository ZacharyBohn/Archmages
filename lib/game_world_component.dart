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
    Color color = Colors.green,
    super.position,
    super.priority = 1,
    super.anchor = Anchor.center,
  }) : super(paint: Paint()..color = color, radius: gameWorld.size);

  static GameWorldComponent from(GameWorld gameWorld) {
    return GameWorldComponent(
      gameWorld: gameWorld,
      color: gameWorld.color,
      position: gameWorld.position,
    );
  }

  GameWorld gameWorld;
  TextComponent? mageCountLabel;
  bool highlighted = false;
  DateTime? _tapDownTime;
  bool _isLongPress = false;
  final longPressDelay = const Duration(milliseconds: 200);

  String get name => gameWorld.name;

  List<String> get connectedWorlds => gameWorld.connectedWorlds;

  int get mageCount => gameWorld.mageCount;

  void setMageCount(int count, Faction faction) {
    gameWorld.mageCount = count;
    gameWorld.faction = faction;
    _updateWorldColorAndAlliance();
  }

  int decrementMages([int count = 1]) {
    if (gameWorld.mageCount > 0) {
      final actualCount = min(count, gameWorld.mageCount);
      gameWorld.mageCount -= actualCount;
      _updateWorldColorAndAlliance();
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
        gameWorld.mageCount = count - gameWorld.mageCount;
        gameWorld.faction = faction;
      } else {
        gameWorld.mageCount -= count;
      }
    }
    _updateWorldColorAndAlliance();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isMounted) {
      return;
    }
    scale = Vector2.all(game.dataStore.componentScale);
    _updateMageCounter();
    _updateHighlightedStatus();
    _updateWorldColorAndAlliance();
  }

  void _updateWorldColorAndAlliance() {
    final oldFaction = gameWorld.faction;
    Faction newFaction;
    if (gameWorld.faction == Faction.evil) {
      setColor(Colors.red);
      newFaction = Faction.evil;
    } else if (gameWorld.faction == Faction.good) {
      setColor(Colors.green);
      newFaction = Faction.good;
    } else {
      setColor(game.dataStore.defaultWorldColor);
      newFaction = Faction.neutral;
    }
    if (oldFaction == newFaction) {
      return;
    }
    game.eventBus.emit(
      OnWorldChangedAliance(oldFaction: oldFaction, newFaction: newFaction),
    );
    gameWorld.faction = newFaction;
  }

  _updateHighlightedStatus() {
    if (game.dataStore.highlightedWorld == gameWorld.name) {
      highlighted = true;
    } else {
      highlighted = false;
    }
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
    print('tap down on game world');
    _tapDownTime = DateTime.now();
    _isLongPress = false;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_tapDownTime != null) {
      final tapDuration = DateTime.now().difference(_tapDownTime!);
      if (tapDuration >= longPressDelay) {
        _isLongPress = true;
      }
    }
    game.eventBus.emit(OnWorldTap(gameWorld.name, isLongPress: _isLongPress));
    _tapDownTime = null;
    _isLongPress = false;
    super.onTapUp(event);
  }

  @override
  void setColor(Color color, {Object? paintId}) {
    gameWorld.color = color;
    super.setColor(color, paintId: paintId);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    return;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (highlighted) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.purpleAccent;
      canvas.drawCircle(Offset(radius, radius), radius + 1, borderPaint);
    }
  }
}
