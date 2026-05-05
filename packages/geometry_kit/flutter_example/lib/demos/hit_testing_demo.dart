import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class HitTestingDemo extends StatefulWidget {
  const HitTestingDemo({super.key});

  @override
  State<HitTestingDemo> createState() => _HitTestingDemoState();
}

class _HitTestingDemoState extends State<HitTestingDemo> {
  gk.Point? _tapPoint;
  String _result = 'Tap anywhere to test';

  late final gk.Polygon _hexagon;
  late final gk.Circle _circle;
  late final gk.Polygon _triangle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final w = MediaQuery.of(context).size.width;
    _hexagon = gk.Polygon.regular(sides: 6, radius: 70, center: gk.Point(w * 0.25, 180));
    _circle = gk.Circle(radius: 60, center: gk.Point(w * 0.75, 180));
    _triangle = gk.Polygon.regular(sides: 3, radius: 70, center: gk.Point(w * 0.5, 370));
  }

  void _onTap(TapDownDetails details) {
    final tap = gk.Point(details.localPosition.dx, details.localPosition.dy);
    String result;

    if (_hexagon.contains(tap)) {
      result = 'Inside hexagon!';
    } else if (_circle.hasPoint(tap)) {
      result = 'Inside circle!';
    } else if (_triangle.contains(tap)) {
      result = 'Inside triangle!';
    } else {
      result = 'Outside all shapes';
    }

    setState(() {
      _tapPoint = tap;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hit Testing')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_result, style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: _onTap,
              child: CustomPaint(
                painter: _HitTestPainter(
                  hexagon: _hexagon,
                  circle: _circle,
                  triangle: _triangle,
                  tapPoint: _tapPoint,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HitTestPainter extends CustomPainter {
  final gk.Polygon hexagon;
  final gk.Circle circle;
  final gk.Polygon triangle;
  final gk.Point? tapPoint;

  _HitTestPainter({
    required this.hexagon,
    required this.circle,
    required this.triangle,
    this.tapPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()..style = PaintingStyle.fill;

    // Hexagon
    stroke.color = Colors.indigo;
    fill.color = Colors.indigo.withValues(alpha: 0.1);
    final hexPath = _polygonPath(hexagon);
    canvas.drawPath(hexPath, fill);
    canvas.drawPath(hexPath, stroke);

    // Circle
    stroke.color = Colors.teal;
    fill.color = Colors.teal.withValues(alpha: 0.1);
    canvas.drawCircle(
      Offset(circle.center.x, circle.center.y),
      circle.radius,
      fill,
    );
    canvas.drawCircle(
      Offset(circle.center.x, circle.center.y),
      circle.radius,
      stroke,
    );

    // Triangle
    stroke.color = Colors.green;
    fill.color = Colors.green.withValues(alpha: 0.1);
    final triPath = _polygonPath(triangle);
    canvas.drawPath(triPath, fill);
    canvas.drawPath(triPath, stroke);

    // Tap indicator
    if (tapPoint != null) {
      final dotPaint = Paint()..color = Colors.red;
      canvas.drawCircle(Offset(tapPoint!.x, tapPoint!.y), 6, dotPaint);
    }
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
  bool shouldRepaint(covariant _HitTestPainter oldDelegate) =>
      tapPoint != oldDelegate.tapPoint;
}
