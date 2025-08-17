import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MageComponent extends SpriteComponent {
  final Color color;
  final int number;
  final double padding; // gap between triangle and text

  late final TextComponent _text;

  MageComponent({
    required this.color,
    required this.number,
    this.padding = 6,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('mage_icon.png');

    _text = TextComponent(
      text: number.toString(),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(size.x + padding, size.y / 2),
    );
    add(_text);
  }

  void updateCount(int count) {
    if (!isMounted) {
      return;
    }
    _text.text = count.toString();
  }
}
