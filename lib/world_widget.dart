import 'package:flutter/material.dart';
import 'package:flutter_rts/data_classes.dart';
import 'package:provider/provider.dart';

import 'game_state.dart';

class WorldWidget extends StatelessWidget {
  final World world;
  const WorldWidget(this.world, {super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<GameState>();
    return Container(
      width: world.radius * 2,
      height: world.radius * 2,
      decoration: BoxDecoration(color: world.color, shape: BoxShape.circle),
      child: Center(child: Text(world.id)),
    );
  }
}
