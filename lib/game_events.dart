import 'package:archmage_rts/factions.dart';

abstract class GameEvent {}

class OnGameStart extends GameEvent {}

class OnWorldTap extends GameEvent {
  OnWorldTap(this.worldName, {this.isLongPress = false});
  String worldName;
  bool isLongPress;
}

class OnBackgroundTapped extends GameEvent {}

class OnGameTick extends GameEvent {
  OnGameTick(this.dt);
  final double dt;
}

class OnEvilMageAITick extends GameEvent {}

class OnWorldChangedAliance extends GameEvent {
  OnWorldChangedAliance({required this.oldFaction, required this.newFaction});
  final Faction oldFaction;
  final Faction newFaction;
}
