import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class PolygonInfoDemo extends StatefulWidget {
  const PolygonInfoDemo({super.key});

  @override
  State<PolygonInfoDemo> createState() => _PolygonInfoDemoState();
}

class _PolygonInfoDemoState extends State<PolygonInfoDemo> {
  int _sides = 6;
  gk.Point? _tapPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polygon Info')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Text('Sides:'),
                Expanded(
                  child: Slider(
                    min: 3,
                    max: 10,
                    divisions: 7,
                    value: _sides.toDouble(),
                    label: '$_sides',
                    onChanged: (v) => setState(() {
                      _sides = v.round();
                      _tapPoint = null;
                    }),
                  ),
                ),
                Text('$_sides'),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final center = gk.Point(
                constraints.maxWidth / 2,
                constraints.maxHeight / 2 - 20,
              );
              final poly = gk.Polygon.regular(
                sides: _sides,
                radius: 120,
                center: center,
              );
              return GestureDetector(
                onTapDown: (d) {
                  setState(() {
                    _tapPoint = gk.Point(
                      d.localPosition.dx,
                      d.localPosition.dy,
                    );
                  });
                },
                child: CustomPaint(
                  painter: _PolyInfoPainter(
                    polygon: poly,
                    tapPoint: _tapPoint,
                  ),
                  size: Size.infinite,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PolyInfoPainter extends CustomPainter {
  final gk.Polygon polygon;
  final gk.Point? tapPoint;

  _PolyInfoPainter({required this.polygon, this.tapPoint});

  @override
  void paint(Canvas canvas, Size size) {
    // Bounding box
    final bound = polygon.getBound();
    final boundRect = Rect.fromLTRB(
      bound.mostLeftPoint.x,
      bound.bottomPoint.y,
      bound.mostRightPoint.x,
      bound.topPoint.y,
    );
    final boundPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(boundRect, boundPaint);
    _drawLabel(canvas, 'bounding box',
        Offset(boundRect.left, boundRect.top - 16), Colors.orange);

    // Polygon fill + stroke
    final fill = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = _polyPath(polygon);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Vertices
    final dotPaint = Paint()..color = Colors.indigo;
    for (final v in polygon.vertices) {
      canvas.drawCircle(Offset(v.x, v.y), 4, dotPaint);
    }

    // Centroid
    final centroid = polygon.centroid;
    final centroidPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(centroid.x, centroid.y), 6, centroidPaint);
    _drawLabel(canvas, 'centroid', Offset(centroid.x + 8, centroid.y - 6),
        Colors.red);

    // Closest vertex to tap
    if (tapPoint != null) {
      final contains = polygon.contains(tapPoint!);
      final tapColor = contains ? Colors.green : Colors.red;
      canvas.drawCircle(Offset(tapPoint!.x, tapPoint!.y), 5,
          Paint()..color = tapColor);

      final closest = polygon.getClosestVertex(tapPoint!);
      final closestLine = Paint()
        ..color = Colors.purple.withValues(alpha: 0.5)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(tapPoint!.x, tapPoint!.y),
        Offset(closest.x, closest.y),
        closestLine,
      );
      canvas.drawCircle(
          Offset(closest.x, closest.y), 6, Paint()..color = Colors.purple);
      _drawLabel(canvas, 'closest vertex',
          Offset(closest.x + 8, closest.y - 16), Colors.purple);
      _drawLabel(
        canvas,
        contains ? 'inside' : 'outside',
        Offset(tapPoint!.x + 8, tapPoint!.y - 6),
        tapColor,
      );
    }

    // Info panel
    final infoX = 16.0;
    final infoY = size.height - 100;
    final isConvex = polygon.isConvex;
    final isClockwise = polygon.isClockwise;

    _drawLabel(canvas, 'convex: ${isConvex ? "yes" : "no"}',
        Offset(infoX, infoY), isConvex ? Colors.green : Colors.red);
    _drawLabel(canvas, 'winding: ${isClockwise ? "CW" : "CCW"}',
        Offset(infoX, infoY + 18), Colors.black87);
    _drawLabel(
        canvas,
        'area: ${polygon.area.toStringAsFixed(1)}',
        Offset(infoX, infoY + 36),
        Colors.black87);
    _drawLabel(
        canvas,
        'perimeter: ${polygon.perimeter.toStringAsFixed(1)}',
        Offset(infoX, infoY + 54),
        Colors.black87);
    _drawLabel(canvas, 'Tap to test containment & closest vertex',
        Offset(infoX, infoY + 76), Colors.grey);
  }

  Path _polyPath(gk.Polygon p) {
    final path = Path();
    path.moveTo(p.vertices.first.x, p.vertices.first.y);
    for (final v in p.vertices.skip(1)) {
      path.lineTo(v.x, v.y);
    }
    path.close();
    return path;
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _PolyInfoPainter old) =>
      polygon.vertices != old.polygon.vertices || tapPoint != old.tapPoint;
}
