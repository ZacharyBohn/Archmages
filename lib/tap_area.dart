import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Canvas;

class TapArea extends PositionComponent with TapCallbacks {
  TapArea({
    required Vector2 position,
    required Vector2 size,
    required this.callback,
  }) : super(position: position, size: size);

  final void Function() callback;

  @override
  void render(Canvas canvas) {
    // nothing drawn
  }

  @override
  void onTapDown(TapDownEvent event) {
    callback();
  }
}
