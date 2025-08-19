import 'package:archmage_rts/game_events.dart';
import 'package:archmage_rts/mage_component.dart';
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
  late TextComponent label;
  MageComponent? mageCounter;
  MageComponent? evilMageCounter;
  double fightCooldown = 1.0;
  double timeSinceLastFight = 0.0;
  bool highlighted = false;
  DateTime? _tapDownTime;
  bool _isLongPress = false;
  final longPressDelay = const Duration(milliseconds: 200);

  String get name => gameWorld.name;

  List<String> get connectedWorlds => gameWorld.connectedWorlds;

  int get goodMageCount => gameWorld.goodMageCount;
  int get evilMageCount => gameWorld.evilMageCount;

  void setMageCount(int count) {
    gameWorld.goodMageCount = count;
    _updateWorldColorAndAlliance();
  }

  void setEvilMageCount(int count) {
    gameWorld.evilMageCount = count;
    _updateWorldColorAndAlliance();
  }

  int decrementMages([int count = 1]) {
    if (gameWorld.goodMageCount > 0) {
      final actualCount = min(count, gameWorld.goodMageCount);
      gameWorld.goodMageCount -= actualCount;
      _updateWorldColorAndAlliance();
      return actualCount;
    }
    return 0;
  }

  void incrementMages(int count) {
    if (count == 0) {
      return;
    }
    gameWorld.goodMageCount += count;
    _updateWorldColorAndAlliance();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isMounted) {
      return;
    }
    scale = Vector2.all(game.dataStore.componentScale);
    _updateGoodMageCounter();
    _updateEvilMageCounter();
    _updateHighlightedStatus();
    _handleFighting(dt);
    _updateWorldColorAndAlliance();
  }

  void _handleFighting(double dt) {
    timeSinceLastFight += dt;
    if (timeSinceLastFight >= fightCooldown) {
      if (gameWorld.goodMageCount > 0 && gameWorld.evilMageCount > 0) {
        gameWorld.goodMageCount--;
        gameWorld.evilMageCount--;
      }
      timeSinceLastFight = 0.0;
    }
  }

  void _updateWorldColorAndAlliance() {
    final oldFaction = gameWorld.faction;
    Faction newFaction;
    if (gameWorld.evilMageCount > gameWorld.goodMageCount) {
      setColor(Colors.red);
      newFaction = Faction.evil;
    } else if (gameWorld.goodMageCount > gameWorld.evilMageCount) {
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

  _updateGoodMageCounter() {
    if (gameWorld.goodMageCount > 0 && mageCounter != null) {
      mageCounter!.updateCount(gameWorld.goodMageCount);
    }
    if (gameWorld.goodMageCount > 0 && mageCounter == null) {
      final padding = 10;
      mageCounter = MageComponent(
        number: gameWorld.goodMageCount,
        position: Vector2(size.x + padding, 0),
        size: Vector2.all(40),
      );
      add(mageCounter!);
    }
    if (gameWorld.goodMageCount == 0 && mageCounter != null) {
      remove(mageCounter!);
      mageCounter = null;
    }
  }

  _updateEvilMageCounter() {
    if (gameWorld.evilMageCount > 0 && evilMageCounter != null) {
      evilMageCounter!.updateCount(gameWorld.evilMageCount);
    }
    if (gameWorld.evilMageCount > 0 && evilMageCounter == null) {
      final padding = 10;
      evilMageCounter = MageComponent(
        isEvil: true,
        number: gameWorld.evilMageCount,
        position: Vector2(size.x + padding, 60),
        size: Vector2.all(40),
        // textOnLeft: true,
      );
      add(evilMageCounter!);
    }
    if (gameWorld.evilMageCount == 0 && evilMageCounter != null) {
      remove(evilMageCounter!);
      evilMageCounter = null;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
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
    label = TextComponent(
      text: gameWorld.name,
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(style: TextStyle(color: Colors.black)),
    );
    add(label);
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
