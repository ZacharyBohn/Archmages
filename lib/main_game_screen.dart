import 'package:flutter/material.dart';
import 'package:flutter_rts/data_classes.dart';
import 'package:flutter_rts/game_state.dart';
import 'package:provider/provider.dart';

import 'camera.dart';
import 'world_widget.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              state.emit(OnPanStart(details));
            },
            onPanUpdate: (details) {
              state.emit(OnPanUpdate(details));
            },
            child: Camera(
              position: state.offset,
              child: Stack(
                children: [
                  // CustomPaint(
                  //   size: Size.infinite,
                  //   painter: ConnectionsPainter(connections: state.connections),
                  // ),
                  // for (final world in state.worlds.values)
                  //   Positioned(
                  //     left: world.position.dx - world.radius,
                  //     top: world.position.dy - world.radius,
                  //     child: GestureDetector(
                  //       onTap: () => state.emit(OnTap(world.id)),
                  //       child: WorldWidget(world),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
          // HUD
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Hud(
              water: 0,
              metal: 0,
              food: 0,
              aura: 0,
              mages: 0,
              foodPerMinute: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class Hud extends StatelessWidget {
  const Hud({
    super.key,
    required this.water,
    required this.metal,
    required this.food,
    required this.aura,
    required this.mages,
    required this.foodPerMinute,
  });

  final int water;
  final int metal;
  final int food;
  final int aura;
  final int mages;
  final int foodPerMinute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Water: $water | Metal: $metal | Food: $food | Aura: $aura',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            SizedBox(width: 4),
            Text(
              'Mages: $mages | Food Consumption: $foodPerMinute/min',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectionsPainter extends CustomPainter {
  final List<Connection> connections;

  ConnectionsPainter({required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint connectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw connections
    for (var connection in connections) {
      connectionPaint.color = connection.color;
      canvas.drawLine(
        connection.world1.position,
        connection.world2.position,
        connectionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
