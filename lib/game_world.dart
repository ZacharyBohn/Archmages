import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

class GameWorld {
  GameWorld(this.name, this.position, this.color);

  String name;
  Vector2 position;
  Color color;
  List<String> connectedWorlds = [];
}
