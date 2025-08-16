import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'game_world.dart';

class GameWorldComponent extends CircleComponent {
  GameWorldComponent({
    required this.name,
    required super.radius,
    required super.position,

    Color color = Colors.green,
    super.priority = 1,
    super.anchor = Anchor.center,
  }) : super(paint: Paint()..color = color);

  static GameWorldComponent from(GameWorld world) {
    return GameWorldComponent(
      name: world.name,
      radius: world.size,
      position: world.position,
      color: world.color,
    );
  }

  String name;
  late TextComponent label;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    label = TextComponent(
      text: name,
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(style: TextStyle(color: Colors.black)),
    );
    add(label);
    return;
  }
}
