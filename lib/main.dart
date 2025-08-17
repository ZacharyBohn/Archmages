import 'package:archmage_rts/event_bus.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:archmage_rts/pannable_game.dart';
import 'game_events.dart';

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
}

class RTSWorld extends World with HasGameReference<RTSGame> {
  // // game world name -> game world component
  // Map<String, GameWorldComponent> gameWorlds = {};
  // // sorted(world1.name, world2.name) -> Component
  // Map<String, PositionComponent> connections = {};
  // Set<MageComponent> travelingMages = {};

  // String? highlightedWorld;

  // final worldBoundaryPadding = 300.0;

  // late final Timer mageGenerator;
  // late final EventBus eventBus;

  @override
  Future<void> onLoad() async {
    // game.eventBus = EventBus(game);
    game.eventBus.emit(OnGameStart());
  }

  // void emit(GameEvent event) {
  //   if (event is OnWorldTap) {
  //     if (highlightedWorld == event.worldName) {
  //       highlightedWorld = null;
  //       return;
  //     }
  //     if (highlightedWorld != null) {
  //       // TODO: animate moving mages
  //       _moveMage(from: highlightedWorld!, to: event.worldName);
  //       highlightedWorld = null;
  //       return;
  //     }
  //     highlightedWorld = event.worldName;
  //     return;
  //   }
  //   if (event is OnBackgroundTapped) {
  //     game.stopPanning();
  //     return;
  //   }
  //   return;
  // }

  // void _moveMage({required String from, required String to}) {
  //   final fromWorld = gameWorlds[from]!;
  //   final toWorld = gameWorlds[to]!;
  //   if (fromWorld.connectedWorlds.contains(to) && fromWorld.mageCount > 0) {
  //     final count = fromWorld.decrementMages();
  //     if (count > 0) {
  //       final mage = MageComponent(number: count, size: Vector2.all(20));
  //       mage.anchor = Anchor.center;

  //       final direction = (toWorld.position - fromWorld.position).normalized();

  //       final startPosition = fromWorld.position + direction * fromWorld.radius;
  //       final endPosition = toWorld.position - direction * toWorld.radius;

  //       mage.position = startPosition;
  //       mage.add(
  //         MoveToEffect(
  //           endPosition,
  //           EffectController(speed: 150),
  //           onComplete: () {
  //             toWorld.incrementMages(count);
  //             mage.removeFromParent();
  //           },
  //         ),
  //       );
  //       add(mage);
  //     }
  //   }
  // }

  @override
  void update(double dt) {
    if (!isMounted) {
      return;
    }
    game.eventBus.emit(OnGameTick(dt));
    // mageGenerator.update(dt);
    // cannot be less than 0
    // this zooms out
    //
    // use += to zoom in
    // game.camera.viewfinder.zoom -= dt;
    // print(highlightedWorld);
    return;
  }

  /// Adds the game world to the FlameWorld
  /// And draws any connections. Connections are guarenteed
  // /// to be drawn only once.
  // void addWorld(GameWorld world) {
  //   final component = GameWorldComponent.from(world);
  //   gameWorlds[world.name] = component;
  //   for (final connectedWorldName in world.connectedWorlds) {
  //     final connection = ([connectedWorldName, world.name]..sort()).toString();
  //     if (connections.keys.contains(connection)) {
  //       continue;
  //     }

  //     final connectedWorld = gameWorlds[connectedWorldName];
  //     if (connectedWorld == null) {
  //       continue;
  //     }

  //     final line = LineComponent(
  //       start: world.position,
  //       end: connectedWorld.position,
  //     );
  //     line.priority = 0;
  //     connections[connection] = line;
  //     add(line);
  //   }
  //   add(component);
  // }
}
