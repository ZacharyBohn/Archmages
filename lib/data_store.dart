import 'package:flame/components.dart';

import 'game_world_component.dart';
import 'mage_component.dart';

class DataStore {
  // game world name -> game world component
  Map<String, GameWorldComponent> gameWorlds = {};
  // sorted(world1.name, world2.name) -> Component
  Map<String, PositionComponent> connections = {};
  Set<MageComponent> travelingMages = {};

  String? highlightedWorld;

  // Only gonna be used temporarily =0
  // #famousLastWords
  late final Timer mageGenerator;

  final worldBoundaryPadding = 300.0;
}
