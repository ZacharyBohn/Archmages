import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

class GameWorld {
  GameWorld(
    this.name,
    this.size,
    this.position,
    this.color, {
    List<String>? connectedWorlds,
  }) : this.connectedWorlds = connectedWorlds ?? [];

  String name;
  double size;
  Vector2 position;
  Color color;
  List<String> connectedWorlds = [];
}
