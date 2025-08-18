import 'package:archmage_rts/data_store.dart';
import 'package:archmage_rts/event_bus.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:archmage_rts/pannable_game.dart';
import 'game_events.dart';

import 'dart:math';

void main() {
  runApp(GameWidget(game: RTSGame(world: RTSWorld())));
}

class RTSGame extends PannableGame<RTSWorld> {
  RTSGame({required super.world})
    : super(
        backgroundColor: Color(0xFF111111),
        worldSize: Vector2(8000, 5000),
      ) {
    eventBus = EventBus(this);
  }

  late final EventBus eventBus;
  final DataStore dataStore = DataStore();
  final Random random = Random();
}

class RTSWorld extends World with HasGameReference<RTSGame> {
  @override
  Future<void> onLoad() async {
    game.eventBus.emit(OnGameStart());

    return;
  }

  @override
  void update(double dt) {
    if (!isMounted) {
      return;
    }
    game.eventBus.emit(OnGameTick(dt));
    // cannot be less than 0
    // this zooms out
    //
    // use += to zoom in
    // game.camera.viewfinder.zoom -= dt;
    // print(highlightedWorld);
    return;
  }
}
