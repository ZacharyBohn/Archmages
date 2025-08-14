import 'dart:math' show max;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';

class PannableGame<T extends World> extends FlameGame<T>
    with PanDetector, ScrollDetector, MultiTouchTapDetector, ScaleDetector {
  PannableGame({
    required super.world,
    required this.worldSize,
    Color? backgroundColor,
  }) : _backgroundColor = backgroundColor ?? Color(0xFFBBBBBB);

  Color _backgroundColor;
  final double minZoom = 0.5;
  final double maxZoom = 3.0;

  @override
  Color backgroundColor() => _backgroundColor;
  final Vector2 worldSize;

  @override
  void onPanUpdate(DragUpdateInfo info) {
    camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
    _clampCamera();
  }

  void _setZoom(double value) {
    camera.viewfinder.zoom = value.clamp(minZoom, maxZoom);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final delta = info.scrollDelta.global.y > 0 ? 0.1 : -0.1;
    _setZoom(camera.viewfinder.zoom + delta);
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    _setZoom(camera.viewfinder.zoom * info.scale.global.x);
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
