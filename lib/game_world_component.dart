import 'package:archmage_rts/factions.dart';
import 'package:archmage_rts/game_events.dart';
import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

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

  // Used to determine when this worlds alliance flips
  Faction _previousFaction = Faction.neutral;
  GameWorld gameWorld;
  late TextComponent _mageCountLabel;

  @override
  Future<void> onLoad() {
    _mageCountLabel = TextComponent(
      text: gameWorld.mageCount.toString(),
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(style: TextStyle(color: Colors.white)),
    );
    add(_mageCountLabel);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isMounted) {
      return;
    }
    scale = Vector2.all(game.dataStore.componentScale);
    _mageCountLabel.text = gameWorld.mageCount.toString();
    setColor(gameWorld.color);
    if (_previousFaction != gameWorld.faction) {
      game.eventBus.emit(
        OnWorldChangedAliance(
          worldName: gameWorld.name,
          oldFaction: _previousFaction,
          newFaction: gameWorld.faction,
        ),
      );
      _previousFaction = gameWorld.faction;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.eventBus.emit(OnWorldTapDown(gameWorld.name));
    super.onTapDown(event);
  }
}
