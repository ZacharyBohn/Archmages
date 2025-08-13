import 'package:flutter/material.dart';

enum WorldType { water, mining, farming, aura, desert, verdant }

enum InfrastructureType {
  waterWell,
  mine,
  farm,
  auraRitualSite,
  mageTower,
  scryingPool,
}

enum ElementalType { fire, water, earth }

class Infrastructure {
  final InfrastructureType type;
  int level;

  Infrastructure({required this.type, this.level = 1});

  String get name {
    switch (type) {
      case InfrastructureType.waterWell:
        return 'Water Well';
      case InfrastructureType.mine:
        return 'Mine';
      case InfrastructureType.farm:
        return 'Farm';
      case InfrastructureType.auraRitualSite:
        return 'Aura Ritual Site';
      case InfrastructureType.mageTower:
        return 'Mage Tower';
      case InfrastructureType.scryingPool:
        return 'Scrying Pool';
    }
  }
}

class WildElemental {
  final ElementalType type;
  int health;

  WildElemental({required this.type, this.health = 100});

  String get name {
    switch (type) {
      case ElementalType.fire:
        return 'Fire Elemental';
      case ElementalType.water:
        return 'Water Elemental';
      case ElementalType.earth:
        return 'Earth Elemental';
    }
  }
}

class World {
  final String id;
  final Offset position;
  final double radius;
  final Color color; // This will be derived from WorldType later
  final WorldType type;
  final Map<String, double> resourceAffinities;
  final List<Infrastructure> infrastructure;
  final List<WildElemental> elementals;

  World({
    required this.id,
    required this.position,
    this.radius = 30.0,
    required this.type,
    required this.resourceAffinities,
    this.infrastructure = const [],
    this.elementals = const [],
  }) : color = _getWorldColor(type);

  static Color _getWorldColor(WorldType type) {
    switch (type) {
      case WorldType.water:
        return Colors.blue;
      case WorldType.mining:
        return Colors.brown;
      case WorldType.farming:
        return Colors.lightGreen;
      case WorldType.aura:
        return Colors.purple;
      case WorldType.desert:
        return Colors.orange;
      case WorldType.verdant:
        return Colors.green;
    }
  }
}

class Connection {
  final World world1;
  final World world2;
  final Color color;

  Connection({
    required this.world1,
    required this.world2,
    this.color = Colors.grey,
  });
}
