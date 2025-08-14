import 'dart:math' show max;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';

class PannableGame<T extends World> extends FlameGame<T>
    with ScrollDetector, MultiTouchTapDetector, ScaleDetector {
  PannableGame({
    required super.world,
    required this.worldSize,
    Color? backgroundColor,
  }) : _backgroundColor = backgroundColor ?? const Color(0xFFBBBBBB);

  final Color _backgroundColor;
  final double minZoom = 0.5;
  final double maxZoom = 3.0;
  late double _startZoom;

  @override
  Color backgroundColor() => _backgroundColor;
  final Vector2 worldSize;

  void _setZoom(double value) {
    camera.viewfinder.zoom = value.clamp(minZoom, maxZoom);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final delta = info.scrollDelta.global.y > 0 ? 0.1 : -0.1;
    _setZoom(camera.viewfinder.zoom + delta);
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      _setZoom(_startZoom * currentScale.y);
    } else {
      camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
      _clampCamera();
    }
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
