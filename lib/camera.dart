import 'package:flutter/material.dart';

class Camera extends StatelessWidget {
  final Offset position;
  final Widget child;

  const Camera({
    super.key,
    required this.position,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: OverflowBox(
        minWidth: 0,
        minHeight: 0,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Transform.translate(offset: -position, child: child),
      ),
    );
  }
}
