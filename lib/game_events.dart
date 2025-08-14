import 'package:flutter/widgets.dart';
import 'package:flutter_rts/data_classes.dart';

abstract class GameEvent {}

class OnPanStart extends GameEvent {
  OnPanStart(this.details);
  final DragStartDetails details;
}

class OnPanUpdate extends GameEvent {
  OnPanUpdate(this.details);
  final DragUpdateDetails details;
}

class OnTap extends GameEvent {
  OnTap(this.worldId);
  final String worldId;
}

class OnBuildInfra extends GameEvent {
  OnBuildInfra(this.worldID, this.type);

  final String worldID;
  final InfrastructureType type;
}

class OnUpgradeInfra extends GameEvent {
  OnUpgradeInfra(this.worldID, this.type);

  final String worldID;
  final InfrastructureType type;
}
