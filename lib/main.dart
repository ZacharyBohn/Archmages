import 'dart:math' show max;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: RTSGame(world: RTSWorld())));
}

class RTSGame extends FlameGame with PanDetector {
  RTSGame({required super.world});

  @override
  Color backgroundColor() => const Color(0xFF111111);

  List connections = [];
  Map worlds = {};
  final Vector2 worldSize = Vector2(1000, 1000);

  @override
  void onPanUpdate(DragUpdateInfo info) {
    camera.viewfinder.position -= info.delta.global;
    _clampCamera();
  }

  void _clampCamera() {
    // Get visible area in world coordinates
    final visibleRect = camera.visibleWorldRect;
    final halfWidth = visibleRect.width / 2;
    final halfHeight = visibleRect.height / 2;

    // Clamp camera center position so the view doesn't leave world bounds
    final minX = halfWidth;
    final maxX = worldSize.x - halfWidth;
    final minY = halfHeight;
    final maxY = worldSize.y - halfHeight;

    camera.viewfinder.position.setValues(
      camera.viewfinder.position.x.clamp(minX, max(maxX, minX)),
      camera.viewfinder.position.y.clamp(minY, max(maxY, minY)),
    );
  }
}

class RTSWorld extends World with HasGameReference<RTSGame> {
  @override
  Future<void> onLoad() async {
    // --- Connections ---
    add(LineComponent(start: Vector2(0, 0), end: Vector2(600, 600)));
    add(LineComponent(start: Vector2(0, 0), end: Vector2(-600, 600)));
    add(LineComponent(start: Vector2(0, 0), end: Vector2(350, 0)));
    // --- Worlds ---
    add(createCircle(Vector2(0, 0), Colors.purple));
    add(createCircle(Vector2(600, 600), Colors.red));
    add(createCircle(Vector2(-600, 600), Colors.blue));
    add(createCircle(Vector2(350, 0), Colors.green));
    // --- HUD ---
    final text = TextComponent(
      text: 'HUD Element',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
    game.camera.viewport.add(text);
  }
}

CircleComponent createCircle(Vector2 pos, Color color) {
  return CircleComponent(radius: 20, paint: Paint()..color = color)
    ..position = pos
    ..anchor = Anchor.center;
}

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
