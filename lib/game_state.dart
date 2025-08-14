import 'package:flutter/material.dart';
import 'package:flutter_rts/main_game_screen.dart';
import 'package:flutter_rts/map_generator.dart';
import 'package:provider/provider.dart';
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
    final map = generateMap(Offset.zero);
    worlds = map.$1;
    connections = map.$2;
    registerHandler<OnPanStart>(_handlePanStart);
    registerHandler<OnPanUpdate>(_handlePanUpdate);
    registerHandler<OnTap>(_handleTap);
    registerHandler<OnBuildInfra>(_handleBuildInfra);
    registerHandler<OnUpgradeInfra>(_handleUpgradeInfra);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerCamera();
    });
  }

  Offset offset = Offset.zero;
  Offset lastFocalPoint = Offset.zero;
  late final Map<String, World> worlds;
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

  void _handlePanStart(OnPanStart event) {
    lastFocalPoint = event.details.globalPosition;
    notifyListeners();
  }

  void _handlePanUpdate(OnPanUpdate event) {
    final details = event.details;
    offset += (details.globalPosition - lastFocalPoint);
    lastFocalPoint = details.globalPosition;
    notifyListeners();
  }

  void _handleTap(OnTap event) async {
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: this,
        child: WorldPopup(event.worldId),
      ),
    );
    notifyListeners();
  }

  void _handleBuildInfra(OnBuildInfra event) {
    worlds[event.worldID]!.infrastructure.add(Infrastructure(type: event.type));
    notifyListeners();
  }

  void _handleUpgradeInfra(OnUpgradeInfra event) {
    worlds[event.worldID]!.infrastructure
            .firstWhere((infra) => infra.type == event.type)
            .level +=
        1;
    notifyListeners();
  }

  // --- Helpers ---

  void _centerCamera() {
    final screenSize = MediaQuery.of(context).size;
    offset = Offset(screenSize.width / 2, screenSize.height / 2);
    notifyListeners();
  }
}
