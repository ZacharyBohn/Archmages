import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LineComponent extends PositionComponent {
  final Vector2 start;
  final Vector2 end;
  final Paint paint;

  LineComponent({
    required this.start,
    required this.end,
    Color color = const Color(0xFFBBBBBB),
    double strokeWidth = 2.0,
  }) : paint = Paint()
         ..color = color
         ..strokeWidth = strokeWidth
         ..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }
}
