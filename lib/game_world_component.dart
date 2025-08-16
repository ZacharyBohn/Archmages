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
  PositionComponent? mageCounter;
  bool highlighted = false;

  void setMageCount(int count) {
    _gameWorld.mageCount = count;
  }

  @override
  void update(double dt) {
    _updateMageCounter();
    _updateHighlightedStatus();
  }

  _updateHighlightedStatus() {
    if (game.world.highlightedWorld == _gameWorld.name) {
      highlighted = true;
    } else {
      highlighted = false;
    }
  }

  _updateMageCounter() {
    if (_gameWorld.mageCount > 0 && mageCounter == null) {
      final padding = 10;
      mageCounter = MageComponent(
        color: Colors.purple,
        number: _gameWorld.mageCount,
        position: Vector2(size.x + padding, 0),
        side: 40,
      );
      add(mageCounter!);
    } else if (_gameWorld.mageCount == 0 && mageCounter != null) {
      mageCounter = null;
      remove(mageCounter!);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.world.emit(OnWorldTap(_gameWorld.name));
    super.onTapDown(event);
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
