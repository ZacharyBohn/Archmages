import 'package:flutter/material.dart';
import 'package:flutter_rts/data_classes.dart';
import 'package:flutter_rts/map_generator.dart';
import 'package:flutter_rts/world_popup.dart';

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

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  Offset _offset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;

  // Example worlds and connections
  final List<World> _worlds = generateMap();

  final List<Connection> _connections = [];

  @override
  void initState() {
    super.initState();
    _connections.addAll([
      Connection(world1: _worlds[0], world2: _worlds[1]),
      Connection(world1: _worlds[1], world2: _worlds[2]),
      Connection(world1: _worlds[2], world2: _worlds[0]),
      Connection(world1: _worlds[1], world2: _worlds[3]),
      Connection(world1: _worlds[3], world2: _worlds[4]),
      Connection(world1: _worlds[4], world2: _worlds[2]),
    ]);
  }

  void _onPanStart(DragStartDetails details) {
    _lastFocalPoint = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += (details.globalPosition - _lastFocalPoint);
      _lastFocalPoint = details.globalPosition;
    });
  }

  void _handleTap(TapUpDetails details) {
    final tapPosition = details.localPosition;
    final adjustedTapPosition = tapPosition - _offset;

    for (var world in _worlds) {
      final distance = (world.position - adjustedTapPosition).distance;
      if (distance <= world.radius) {
        _showWorldPopup(world);
        break;
      }
    }
  }

  void _showWorldPopup(World world) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WorldPopup(
          world: world,
          onBuild: _onBuildInfrastructure,
          onUpgrade: _onUpgradeInfrastructure,
        );
      },
    );
  }

  void _onBuildInfrastructure(World world, InfrastructureType type) {
    // TODO: redo this, why not just do an update?
    setState(() {
      final newInfrastructure = Infrastructure(type: type);
      final updatedInfrastructureList = List<Infrastructure>.from(
        world.infrastructure,
      )..add(newInfrastructure);

      final updatedWorld = World(
        id: world.id,
        position: world.position,
        type: world.type,
        resourceAffinities: world.resourceAffinities,
        infrastructure: updatedInfrastructureList,
        elementals: world.elementals,
      );

      final worldIndex = _worlds.indexOf(world);
      if (worldIndex != -1) {
        _worlds[worldIndex] = updatedWorld;
      }
    });
    // Navigator.of(context).pop(); // Close the popup
  }

  void _onUpgradeInfrastructure(World world, Infrastructure infrastructure) {
    // TODO: redo this, why not just do an update?
    setState(() {
      final updatedInfrastructure = Infrastructure(
        type: infrastructure.type,
        level: infrastructure.level + 1,
      );

      final updatedInfrastructureList = world.infrastructure.map((infra) {
        return infra == infrastructure ? updatedInfrastructure : infra;
      }).toList();

      final updatedWorld = World(
        id: world.id,
        position: world.position,
        type: world.type,
        resourceAffinities: world.resourceAffinities,
        infrastructure: updatedInfrastructureList,
        elementals: world.elementals,
      );

      final worldIndex = _worlds.indexOf(world);
      if (worldIndex != -1) {
        _worlds[worldIndex] = updatedWorld;
      }
    });
    // Navigator.of(context).pop(); // Close the popup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onTapUp: _handleTap, // Add onTapUp here
            child: Transform.translate(
              offset: _offset,
              child: CustomPaint(
                size: Size.infinite, // Take all available space
                painter: WorldMapPainter(
                  worlds: _worlds,
                  connections: _connections,
                ),
              ),
            ),
          ),
          // HUD
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.all(8.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resources:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Water: 100 | Metal: 50 | Food: 75 | Aura: 25',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mages: 5 | Food Consumption: 10/min',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
