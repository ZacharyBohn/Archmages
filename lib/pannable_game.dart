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
    this.onDrag,
    this.onDragEnd,
    this.freedomPadding = 500.0,
    Color? backgroundColor,
  });

  final double minZoom = 0.25;
  final double maxZoom = 5.0;
  final double freedomPadding;
  late double _startZoom;
  Vector2 _panVelocity = Vector2.zero();
  final _panDecayStop = 7.0;
  static const double _panFriction = 2.5;
  final Vector2 worldSize;
  void Function(Vector2 delta)? onDrag;
  void Function()? onDragEnd;

  void stopPanning() {
    _panVelocity = Vector2.zero();
  }

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
    // This function is called during a drag
    _panVelocity = Vector2.zero();
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      _setZoom(_startZoom * currentScale.y);
    } else {
      onDrag?.call(info.delta.global / camera.viewfinder.zoom);
    }
  }

  void pan(Vector2 delta) {
    camera.viewfinder.position -= delta;
    _clampCamera();
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    _panVelocity = info.velocity.global;
    onDragEnd?.call();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_panVelocity.length2 > 1) {
      pan(_panVelocity * dt / camera.viewfinder.zoom);
      _panVelocity *= 1 - (_panFriction * dt);
      if (_panVelocity.length < _panDecayStop) {
        _panVelocity = Vector2.zero();
      }
    }
  }

  void _clampCamera() {
    // Get visible area in world coordinates
    final visibleRect = camera.visibleWorldRect;
    final halfWidth = visibleRect.width / 2;
    final halfHeight = visibleRect.height / 2;

    // Clamp camera center position so the view doesn't leave world bounds
    final minX = (-worldSize.x / 2 + halfWidth) - freedomPadding;
    final maxX = (worldSize.x / 2 - halfWidth) + freedomPadding;
    final minY = (-worldSize.y / 2 + halfHeight) - freedomPadding;
    final maxY = (worldSize.y / 2 - halfHeight) + freedomPadding;

    final camX = camera.viewfinder.position.x;
    final camY = camera.viewfinder.position.y;

    camera.viewfinder.position = Vector2(
      camX.clamp(minX, maxX),
      camY.clamp(minY, maxY),
    );
  }
}
