import 'package:archmage_rts/game_events.dart';
import 'package:archmage_rts/mage_component.dart';
import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'game_world.dart';

class GameWorldComponent extends CircleComponent
    with TapCallbacks, HasGameReference<RTSGame> {
  GameWorldComponent({
    required GameWorld gameWorld,
    Color color = Colors.green,
    super.position,
    super.priority = 1,
    super.anchor = Anchor.center,
  }) : _gameWorld = gameWorld,
       super(paint: Paint()..color = color, radius: gameWorld.size);

  static GameWorldComponent from(GameWorld gameWorld) {
    return GameWorldComponent(
      gameWorld: gameWorld,
      color: gameWorld.color,
      position: gameWorld.position,
    );
  }

  GameWorld _gameWorld;
  late TextComponent label;
  MageComponent? mageCounter;
  MageComponent? evilMageCounter;
  double fightCooldown = 1.0;
  double timeSinceLastFight = 0.0;
  bool highlighted = false;

  List<String> get connectedWorlds => _gameWorld.connectedWorlds;

  int get mageCount => _gameWorld.goodMageCount;
  int get evilMageCount => _gameWorld.evilMageCount;

  void setMageCount(int count) {
    _gameWorld.goodMageCount = count;
    _updateWorldColor();
  }

  void setEvilMageCount(int count) {
    _gameWorld.evilMageCount = count;
    _updateWorldColor();
  }

  int decrementMages() {
    // TODO
    // maybe make this more than 1 optional
    if (_gameWorld.goodMageCount > 0) {
      _gameWorld.goodMageCount -= 1;
      _updateWorldColor();
      return 1;
    }
    return 0;
  }

  void incrementMages(int count) {
    if (count == 0) {
      return;
    }
    _gameWorld.goodMageCount += count;
    _updateWorldColor();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isMounted) {
      return;
    }
    _updateGoodMageCounter();
    _updateEvilMageCounter();
    _updateHighlightedStatus();
    _handleFighting(dt);
    _updateWorldColor();
  }

  void _handleFighting(double dt) {
    timeSinceLastFight += dt;
    if (timeSinceLastFight >= fightCooldown) {
      if (_gameWorld.goodMageCount > 0 && _gameWorld.evilMageCount > 0) {
        _gameWorld.goodMageCount--;
        _gameWorld.evilMageCount--;
      }
      timeSinceLastFight = 0.0;
    }
  }

  void _updateWorldColor() {
    if (_gameWorld.evilMageCount > _gameWorld.goodMageCount) {
      setColor(Colors.red);
    } else if (_gameWorld.goodMageCount > _gameWorld.evilMageCount) {
      setColor(Colors.green);
    } else {
      setColor(game.dataStore.defaultWorldColor);
    }
  }

  _updateHighlightedStatus() {
    if (game.dataStore.highlightedWorld == _gameWorld.name) {
      highlighted = true;
    } else {
      highlighted = false;
    }
  }

  _updateGoodMageCounter() {
    if (_gameWorld.goodMageCount > 0 && mageCounter != null) {
      mageCounter!.updateCount(_gameWorld.goodMageCount);
    }
    if (_gameWorld.goodMageCount > 0 && mageCounter == null) {
      final padding = 10;
      mageCounter = MageComponent(
        number: _gameWorld.goodMageCount,
        position: Vector2(size.x + padding, 0),
        size: Vector2.all(40),
      );
      add(mageCounter!);
    }
    if (_gameWorld.goodMageCount == 0 && mageCounter != null) {
      remove(mageCounter!);
      mageCounter = null;
    }
  }

  _updateEvilMageCounter() {
    if (_gameWorld.evilMageCount > 0 && evilMageCounter != null) {
      evilMageCounter!.updateCount(_gameWorld.evilMageCount);
    }
    if (_gameWorld.evilMageCount > 0 && evilMageCounter == null) {
      final padding = 10;
      evilMageCounter = MageComponent(
        isEvil: true,
        number: _gameWorld.evilMageCount,
        position: Vector2(-size.x - padding, 0),
        size: Vector2.all(40),
        textOnLeft: true,
      );
      add(evilMageCounter!);
    }
    if (_gameWorld.evilMageCount == 0 && evilMageCounter != null) {
      remove(evilMageCounter!);
      evilMageCounter = null;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.eventBus.emit(OnWorldTap(_gameWorld.name));
    super.onTapUp(event);
  }

  @override
  void setColor(Color color, {Object? paintId}) {
    _gameWorld.color = color;
    super.setColor(color, paintId: paintId);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    label = TextComponent(
      text: _gameWorld.name,
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
