import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MageComponent extends PositionComponent {
  final Color color;
  final int number;
  final double side; // length of each side of the equilateral triangle
  final double padding; // gap between triangle and text

  late final TextComponent _text;
  late final double _h; // equilateral height = side * sqrt(3) / 2

  MageComponent({
    required this.color,
    required this.number,
    required this.side,
    this.padding = 6,
    super.position,
  }) : super(size: Vector2(side, side * math.sqrt(3) / 2)) {
    _h = side * math.sqrt(3) / 2;
  }

  @override
  Future<void> onLoad() async {
    _text = TextComponent(
      text: number.toString(),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(size.x + padding, _h / 2),
    );
    add(_text);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = color;

    final path = Path()
      ..moveTo(0, _h) // bottom-left
      ..lineTo(side, _h) // bottom-right
      ..lineTo(side / 2, 0) // top apex
      ..close();

    canvas.drawPath(path, paint);
  }
}
