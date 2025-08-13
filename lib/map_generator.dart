import 'package:flutter/material.dart' show Offset;
import 'package:flutter_rts/data_classes.dart';

List<World> generateMap() {
  return [
    World(
      id: 'W1',
      position: Offset(200, 200),
      type: WorldType.verdant,
      resourceAffinities: {
        'water': 1.0,
        'metal': 1.0,
        'food': 1.0,
        'aura': 1.0,
      },
      infrastructure: [
        Infrastructure(type: InfrastructureType.waterWell, level: 1),
        Infrastructure(type: InfrastructureType.mageTower, level: 1),
      ],
      elementals: [WildElemental(type: ElementalType.fire)],
    ),
    World(
      id: 'W2',
      position: Offset(400, 300),
      type: WorldType.mining,
      resourceAffinities: {
        'water': 0.5,
        'metal': 2.0,
        'food': 0.5,
        'aura': 1.0,
      },
      infrastructure: [Infrastructure(type: InfrastructureType.mine, level: 2)],
      elementals: [WildElemental(type: ElementalType.earth)],
    ),
    World(
      id: 'W3',
      position: Offset(300, 500),
      type: WorldType.water,
      resourceAffinities: {
        'water': 2.0,
        'metal': 0.5,
        'food': 1.0,
        'aura': 1.0,
      },
      infrastructure: [Infrastructure(type: InfrastructureType.farm, level: 1)],
      elementals: [],
    ),
    World(
      id: 'W4',
      position: Offset(600, 250),
      type: WorldType.aura,
      resourceAffinities: {
        'water': 1.0,
        'metal': 1.0,
        'food': 1.0,
        'aura': 2.0,
      },
      infrastructure: [
        Infrastructure(type: InfrastructureType.auraRitualSite, level: 1),
      ],
      elementals: [WildElemental(type: ElementalType.water)],
    ),
    World(
      id: 'W5',
      position: Offset(500, 450),
      type: WorldType.desert,
      resourceAffinities: {
        'water': 0.25,
        'metal': 1.25,
        'food': 0.25,
        'aura': 0.5,
      },
      infrastructure: [],
      elementals: [],
    ),
  ];
}
