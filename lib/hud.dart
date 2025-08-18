import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Hud extends PositionComponent with HasGameReference<RTSGame> {
  late final TextComponent goodWorldCountComponent;
  late final TextComponent evilWorldCountComponent;

  @override
  Future<void> onLoad() async {
    goodWorldCountComponent = TextComponent(
      text: 'Good Worlds: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
    add(goodWorldCountComponent);
    evilWorldCountComponent = TextComponent(
      text: 'Evil Worlds: 0',
      position: Vector2(game.size.x - 10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      anchor: Anchor.topRight,
    );
    add(evilWorldCountComponent);
  }

  @override
  void update(double dt) {
    goodWorldCountComponent.text =
        'Good Worlds: ${game.dataStore.goodWorldCount}';
    evilWorldCountComponent.text =
        'Evil Worlds: ${game.dataStore.evilWorldCount}';
    return;
  }
}
