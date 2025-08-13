import 'package:flutter/material.dart';
import 'package:flutter_rts/data_classes.dart';
import 'package:flutter_rts/game_state.dart';
import 'package:flutter_rts/map_generator.dart';
import 'package:flutter_rts/world_popup.dart';
import 'package:provider/provider.dart';

class GameView extends StatelessWidget {
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
            onTapUp: (details) {
              state.emit(OnTap(details));
            },
            child: Transform.translate(
              offset: state.offset,
              child: CustomPaint(
                size: Size.infinite,
                painter: WorldMapPainter(
                  worlds: state.worlds,
                  connections: state.connections,
                ),
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

class WorldMapPainter extends CustomPainter {
  final List<World> worlds;
  final List<Connection> connections;

  WorldMapPainter({required this.worlds, required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint worldPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

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

    // Draw worlds
    for (var world in worlds) {
      worldPaint.color = world.color;
      canvas.drawCircle(world.position, world.radius, worldPaint);

      // Draw world ID
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: world.id,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        world.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // For simplicity, always repaint for now
  }
}
