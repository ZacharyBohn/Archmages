import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MageComponent extends SpriteComponent {
  final int number;
  final double padding;
  final bool isEvil;
  final bool textOnLeft;
  late final TextComponent _text;
  Vector2 velocity;

  MageComponent({
    required this.number,
    this.padding = 6,
    this.isEvil = false,
    this.textOnLeft = false,
    Vector2? velocity,
    super.position,
    super.size,
  }) : this.velocity = velocity ?? Vector2.zero();

  @override
  Future<void> onLoad() async {
    final iconPath = isEvil ? 'evil_mage_icon.png' : 'mage_icon.png';
    sprite = await Sprite.load(iconPath);

    _text = TextComponent(
      text: number.toString(),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      anchor: textOnLeft ? Anchor.centerRight : Anchor.centerLeft,
      position: textOnLeft
          ? Vector2(-padding, size.y / 2)
          : Vector2(size.x + padding, size.y / 2),
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
