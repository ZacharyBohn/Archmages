abstract class GameEvent {}

class OnWorldTap extends GameEvent {
  OnWorldTap(this.worldName);
  String worldName;
}

class OnBackgroundTapped extends GameEvent {}
