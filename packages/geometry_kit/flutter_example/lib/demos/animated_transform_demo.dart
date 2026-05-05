import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class AnimatedTransformDemo extends StatefulWidget {
  const AnimatedTransformDemo({super.key});

  @override
  State<AnimatedTransformDemo> createState() => _AnimatedTransformDemoState();
}

class _AnimatedTransformDemoState extends State<AnimatedTransformDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _sides = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Transforms')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                const Text('Sides:'),
                Expanded(
                  child: Slider(
                    min: 3,
                    max: 12,
                    divisions: 9,
                    value: _sides.toDouble(),
                    label: '$_sides',
                    onChanged: (v) => setState(() => _sides = v.round()),
                  ),
                ),
                Text('$_sides'),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _AnimatedShapePainter(
                    rotation: _controller.value * 360,
                    sides: _sides,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedShapePainter extends CustomPainter {
  final double rotation;
  final int sides;

  _AnimatedShapePainter({required this.rotation, required this.sides});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final base = gk.Polygon.regular(
      sides: sides,
      radius: 80,
      center: gk.Point(0, 0),
    );

    // Rotate then translate to center
    final rotated = base.rotate(rotation);
    final centered = rotated.translate(x: cx, y: cy);

    // Draw filled shape
    final fill = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = _polygonPath(centered);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Draw vertices as dots
    final dotPaint = Paint()..color = Colors.indigo;
    for (final v in centered.vertices) {
      canvas.drawCircle(Offset(v.x, v.y), 4, dotPaint);
    }

    // Draw centroid
    final centroid = centered.getCircumCentroid();
    final centroidPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(centroid.x, centroid.y), 5, centroidPaint);
  }

  Path _polygonPath(gk.Polygon polygon) {
    final path = Path();
    path.moveTo(polygon.vertices.first.x, polygon.vertices.first.y);
    for (final v in polygon.vertices.skip(1)) {
      path.lineTo(v.x, v.y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _AnimatedShapePainter old) =>
      rotation != old.rotation || sides != old.sides;
}
