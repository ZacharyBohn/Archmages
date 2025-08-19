import 'package:archmage_rts/factions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

class GameWorld {
  GameWorld(
    this.name,
    this.size,
    this.position,
    this.color, {
    this.mageCount = 0,
    this.faction = Faction.neutral,
    List<String>? connectedWorlds,
  }) : this.connectedWorlds = connectedWorlds ?? [];

  String name;
  double size;
  Vector2 position;
  Color color;
  List<String> connectedWorlds = [];
  int mageCount;
  Faction faction;
}
