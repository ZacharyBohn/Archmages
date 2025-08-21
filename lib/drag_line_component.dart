import 'dart:math';

import 'package:archmage_rts/main.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DragLineComponent extends PositionComponent
    with HasGameReference<RTSGame> {
  Vector2 origin;
  Vector2 end;
  final Paint paint;

  DragLineComponent({
    required this.origin,
    required this.end,
    super.priority = 2,
  }) : paint = Paint()
         ..color = Colors.green
         ..strokeWidth = 3.0
         ..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawLine(origin.toOffset(), end.toOffset(), paint);
    _drawArrow(canvas);
  }

  void _drawArrow(Canvas canvas) {
    final angle = atan2(end.y - origin.y, end.x - origin.x);
    const arrowSize = 15.0;
    final path = Path();
    path.moveTo(
      end.x - arrowSize * cos(angle - pi / 6),
      end.y - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(end.x, end.y);
    path.lineTo(
      end.x - arrowSize * cos(angle + pi / 6),
      end.y - arrowSize * sin(angle + pi / 6),
    );
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    // if (game.dataStore.dragFromWorldCursorPosition != null) {
    //   end = game.dataStore.dragFromWorldCursorPosition!;
    // }
    super.update(dt);
  }
}
