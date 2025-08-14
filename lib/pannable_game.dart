import 'dart:math' show max;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';

class PannableGame<T extends World> extends FlameGame<T> with PanDetector {
  PannableGame({
    required super.world,
    required this.worldSize,
    Color? backgroundColor,
  }) : _backgroundColor = backgroundColor ?? Color(0xFFBBBBBB);

  Color _backgroundColor;

  @override
  Color backgroundColor() => _backgroundColor;
  final Vector2 worldSize;

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
