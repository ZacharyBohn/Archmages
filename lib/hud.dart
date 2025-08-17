import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Hud extends PositionComponent with HasGameReference<RTSGame> {
  late final TextComponent hudElement;

  @override
  Future<void> onLoad() async {
    hudElement = TextComponent(
      text: 'HUD Element',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
    add(hudElement);
  }

  @override
  void update(double dt) {
    if (game.dataStore.highlightedWorld == null) {
      hudElement.text = 'Selected: None';
    } else {
      hudElement.text = 'Selected: ${game.dataStore.highlightedWorld}';
    }
    return;
  }
}
