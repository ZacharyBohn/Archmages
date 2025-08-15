import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

import 'line_component.dart';

class WorldBoundary extends PositionComponent {
  WorldBoundary(this.worldSize, this.padding);

  final Vector2 worldSize;
  final double padding;

  @override
  Future<void> onLoad() async {
    final topLeft =
        Vector2(-(worldSize.x / 2), -(worldSize.y / 2)) +
        Vector2(-padding, -padding);
    final topRight =
        Vector2(worldSize.x / 2, -(worldSize.y / 2)) +
        Vector2(padding, -padding);
    final bottomRight =
        Vector2(worldSize.x / 2, worldSize.y / 2) + Vector2(padding, padding);
    final bottomLeft =
        Vector2(-(worldSize.x / 2), worldSize.y / 2) +
        Vector2(-padding, padding);
    final color = Color(0xFF102050);
    add(LineComponent(start: topLeft, end: topRight, color: color));
    add(LineComponent(start: topRight, end: bottomRight, color: color));
    add(
      LineComponent(
        start: bottomRight,
        end: bottomLeft,
        color: Color(0xFF114477),
      ),
    );
    add(LineComponent(start: bottomLeft, end: topLeft, color: color));
  }
}
