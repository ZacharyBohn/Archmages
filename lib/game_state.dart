import 'package:flutter/material.dart';
import 'package:flutter_rts/main_game_screen.dart';
import 'package:flutter_rts/map_generator.dart';
import 'package:state_view/state_view.dart';

import 'data_classes.dart';
import 'world_popup.dart';

import 'game_events.dart';
export 'game_events.dart';

class Game extends StateView<GameState> {
  Game({super.key})
    : super(stateBuilder: (context) => GameState(context), view: GameView());
}

class GameState extends StateProvider<Game, GameEvent> {
  GameState(super.context) {
    // TODO
    // Adding world / connections should be one thing
    connections = [
      Connection(world1: worlds[0], world2: worlds[1]),
      Connection(world1: worlds[1], world2: worlds[2]),
      Connection(world1: worlds[2], world2: worlds[0]),
      Connection(world1: worlds[1], world2: worlds[3]),
      Connection(world1: worlds[3], world2: worlds[4]),
      Connection(world1: worlds[4], world2: worlds[2]),
    ];
    registerHandler<OnPanStart>(_onPanStart);
  }

  Offset offset = Offset.zero;
  Offset lastFocalPoint = Offset.zero;

  final List<World> worlds = generateMap();

  late final List<Connection> connections;

  int get water => _water;
  int _water = 0;
  int get metal => _metal;
  int _metal = 0;
  int get food => _food;
  int _food = 0;
  int get aura => _aura;
  int _aura = 0;
  int get mages => _mages;
  int _mages = 0;
  int get foodPerMinute => _foodPerMinute;
  int _foodPerMinute = 0;

  // --- Handlers ---

  void _onPanStart(OnPanStart event) {
    lastFocalPoint = event.details.globalPosition;
  }

  void _onPanUpdate(OnPanUpdate event) {
    final details = event.details;
    offset += (details.globalPosition - lastFocalPoint);
    lastFocalPoint = details.globalPosition;
  }

  void _handleTap(TapUpDetails details) {
    final tapPosition = details.localPosition;
    final adjustedTapPosition = tapPosition - offset;

    for (var world in worlds) {
      final distance = (world.position - adjustedTapPosition).distance;
      if (distance <= world.radius) {
        _showWorldPopup(world);
        break;
      }
    }
  }

  void _showWorldPopup(World world) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WorldPopup(
          world: world,
          onBuild: _onBuildInfrastructure,
          onUpgrade: _onUpgradeInfrastructure,
        );
      },
    );
  }

  void _onBuildInfrastructure(World world, InfrastructureType type) {
    // TODO: redo this, why not just do an update?
    final newInfrastructure = Infrastructure(type: type);
    final updatedInfrastructureList = List<Infrastructure>.from(
      world.infrastructure,
    )..add(newInfrastructure);

    final updatedWorld = World(
      id: world.id,
      position: world.position,
      type: world.type,
      resourceAffinities: world.resourceAffinities,
      infrastructure: updatedInfrastructureList,
      elementals: world.elementals,
    );

    final worldIndex = worlds.indexOf(world);
    if (worldIndex != -1) {
      worlds[worldIndex] = updatedWorld;
    }
    // Navigator.of(context).pop(); // Close the popup
  }

  void _onUpgradeInfrastructure(World world, Infrastructure infrastructure) {
    // TODO: redo this, why not just do an update?
    final updatedInfrastructure = Infrastructure(
      type: infrastructure.type,
      level: infrastructure.level + 1,
    );

    final updatedInfrastructureList = world.infrastructure.map((infra) {
      return infra == infrastructure ? updatedInfrastructure : infra;
    }).toList();

    final updatedWorld = World(
      id: world.id,
      position: world.position,
      type: world.type,
      resourceAffinities: world.resourceAffinities,
      infrastructure: updatedInfrastructureList,
      elementals: world.elementals,
    );

    final worldIndex = worlds.indexOf(world);
    if (worldIndex != -1) {
      worlds[worldIndex] = updatedWorld;
    }
    // Navigator.of(context).pop(); // Close the popup
  }
}
