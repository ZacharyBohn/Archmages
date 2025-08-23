import 'package:archmage_rts/drag_line_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color, Colors;

import 'game_world_component.dart';
import 'mage_component.dart';

class DataStore {
  // game world name -> game world component
  Map<String, GameWorldComponent> gameWorlds = {};
  // sorted(world1.name, world2.name) -> Component
  Map<String, PositionComponent> connections = {};
  Set<MageComponent> travelingMages = {};

  int goodWorldCount = 1;
  int evilWorldCount = 1;

  double componentScale = 1.0;
  final double minDistanceBetweenWorlds = 150.0;
  final double worldRadius = 45.0;

  // Only gonna be used temporarily =0
  // #famousLastWords
  late final Timer mageGenerator;
  late final Timer evilMageAI;

  final worldBoundaryPadding = 300.0;

  final defaultWorldColor = Color(0xFF505050);
  final goodWorldColor = Colors.green;
  final evilWorldColor = Colors.red;

  final maxWorldPopulation = 36;

  bool setupComplete = false;

  GameWorldComponent? dragFromWorld;
  DragLineComponent? dragLine;

  final Map<String, String> moveCommandsMapping = {};

  final Map<String, Timer> moveCommandTimers = {};
}
