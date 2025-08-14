import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rts/pannable_game.dart';

import 'line_component.dart';

void main() {
  runApp(GameWidget(game: RTSGame(world: RTSWorld())));
}

class RTSGame extends PannableGame<RTSWorld> {
  RTSGame({required super.world})
    : super(backgroundColor: Color(0xFF111111), worldSize: Vector2(1000, 1000));
}

class RTSWorld extends World with HasGameReference<RTSGame> {
  List connections = [];
  Map worlds = {};

  @override
  Future<void> onLoad() async {
    // --- Connections ---
    add(LineComponent(start: Vector2(0, 0), end: Vector2(600, 600)));
    add(LineComponent(start: Vector2(0, 0), end: Vector2(-600, 600)));
    add(LineComponent(start: Vector2(0, 0), end: Vector2(350, 0)));
    // --- Worlds ---
    add(createCircle(Vector2(0, 0), Colors.purple));
    add(createCircle(Vector2(600, 600), Colors.red));
    add(createCircle(Vector2(-600, 600), Colors.blue));
    add(createCircle(Vector2(350, 0), Colors.green));
    // --- HUD ---
    final text = TextComponent(
      text: 'HUD Element',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
    game.camera.viewport.add(text);
  }

  @override
  void update(double dt) {
    // cannot be less than 0
    // this zooms out
    //
    // use += to zoom in
    game.camera.viewfinder.zoom -= dt;
    return;
  }
}

CircleComponent createCircle(Vector2 pos, Color color) {
  return CircleComponent(radius: 20, paint: Paint()..color = color)
    ..position = pos
    ..anchor = Anchor.center;
}
