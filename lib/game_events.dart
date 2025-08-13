import 'package:flutter/widgets.dart';

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
  OnTap(this.details);
  final TapUpDetails details;
}
