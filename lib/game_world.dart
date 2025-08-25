import 'package:archmage_rts/factions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color, Colors;

class GameWorld {
  GameWorld(
    this.name,
    this.size,
    this.position, {
    List<String>? connectedWorlds,
  }) : this.connectedWorlds = connectedWorlds ?? [];

  String name;
  double size;
  Vector2 position;
  Color get color {
    switch (_faction) {
      case Faction.neutral:
        return Color(0xFF252525);
      case Faction.evil:
        return Colors.red;
      case Faction.good:
        return Colors.green;
    }
  }

  List<String> connectedWorlds = [];
  int get mageCount => _mageCount;
  int _mageCount = 0;
  Faction get faction => _faction;
  Faction _faction = Faction.neutral;

  void addMages({int count = 1, required Faction incomingFaction}) {
    if (incomingFaction != this.faction) {
      _mageCount -= count;
      if (_mageCount <= 0) {
        _faction = incomingFaction;
        _mageCount = -_mageCount;
      }
    } else {
      _mageCount += count;
    }
  }

  void removeMages({int count = 1}) {
    assert(count <= _mageCount);
    _mageCount -= count;
    if (_mageCount == 0) {
      _faction = Faction.neutral;
    }
  }
}
