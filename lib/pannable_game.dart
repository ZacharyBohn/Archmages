import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';

// TODO: fix panning on web for trackpad
class PannableGame<T extends World> extends FlameGame<T>
    with ScrollDetector, ScaleDetector {
  PannableGame({
    required super.world,
    required this.worldSize,
    Color? backgroundColor,
  }) : _backgroundColor = backgroundColor ?? const Color(0xFFBBBBBB);

  final Color _backgroundColor;
  final double minZoom = 0.5;
  final double maxZoom = 5.0;
  late double _startZoom;
  Vector2 _panVelocity = Vector2.zero();
  final _panDecayStop = 7.0;
  static const double _panFriction = 2.5;
  final Vector2 worldSize;

  void stopPanning() {
    _panVelocity = Vector2.zero();
  }

  @override
  Color backgroundColor() => _backgroundColor;

  void _setZoom(double value) {
    camera.viewfinder.zoom = value.clamp(minZoom, maxZoom);
    onZoomChanged(camera.viewfinder.zoom);
  }

  void onZoomChanged(double value) {}

  @override
  void onScroll(PointerScrollInfo info) {
    // Passing in global.y will kinda fix trackpad
    // super zooming
    final scrollingUp = info.scrollDelta.global.y > 0;
    final delta = scrollingUp ? 0.1 : -0.1;
    _setZoom(camera.viewfinder.zoom + delta);
    _clampCamera();
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
    _panVelocity = Vector2.zero();
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    _panVelocity = Vector2.zero();
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      _setZoom(_startZoom * currentScale.y);
    } else {
      camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
      _clampCamera();
    }
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    _panVelocity = info.velocity.global;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_panVelocity.length2 > 1) {
      camera.viewfinder.position -= _panVelocity * dt / camera.viewfinder.zoom;
      _panVelocity *= 1 - (_panFriction * dt);
      if (_panVelocity.length < _panDecayStop) {
        _panVelocity = Vector2.zero();
      }
      _clampCamera();
    }
  }

  void _clampCamera() {
    // Get visible area in world coordinates
    final visibleRect = camera.visibleWorldRect;
    final halfWidth = visibleRect.width / 2;
    final halfHeight = visibleRect.height / 2;

    // Clamp camera center position so the view doesn't leave world bounds
    final minX = -(halfWidth + worldSize.x / 2);
    final maxX = halfWidth + worldSize.x / 2;
    final minY = -(halfHeight + worldSize.y / 2);
    final maxY = halfHeight + worldSize.y / 2;

    final camX = camera.viewfinder.position.x;
    final camY = camera.viewfinder.position.y;

    camera.viewfinder.position = Vector2(
      camX.clamp(minX, maxX),
      camY.clamp(minY, maxY),
    );
  }
}
