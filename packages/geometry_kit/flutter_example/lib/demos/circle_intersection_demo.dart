import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class CircleIntersectionDemo extends StatefulWidget {
  const CircleIntersectionDemo({super.key});

  @override
  State<CircleIntersectionDemo> createState() =>
      _CircleIntersectionDemoState();
}

class _CircleIntersectionDemoState extends State<CircleIntersectionDemo> {
  gk.Point _center1 = gk.Point(150, 280);
  gk.Point _center2 = gk.Point(260, 280);
  int _dragging = 0; // 0=none, 1=circle1, 2=circle2

  static const _r1 = 90.0;
  static const _r2 = 70.0;

  void _onPanStart(DragStartDetails d) {
    final p = gk.Point(d.localPosition.dx, d.localPosition.dy);
    final d1 = _center1.distanceTo(p);
    final d2 = _center2.distanceTo(p);
    if (d1 < d2 && d1 < _r1 + 30) {
      _dragging = 1;
    } else if (d2 < _r2 + 30) {
      _dragging = 2;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      final p = gk.Point(d.localPosition.dx, d.localPosition.dy);
      if (_dragging == 1) _center1 = p;
      if (_dragging == 2) _center2 = p;
    });
  }

  void _onPanEnd(DragEndDetails _) => _dragging = 0;

  @override
  Widget build(BuildContext context) {
    final c1 = gk.Circle(radius: _r1, center: _center1);
    final c2 = gk.Circle(radius: _r2, center: _center2);
    final intersects = c1.intersectsCircle(c2);
    final points = c1.getCircleIntersections(c2);

    // Tangent at first intersection point (if any)
    gk.Line? tangent;
    if (points.isNotEmpty) {
      tangent = c1.tangentAt(points.first);
    }

    // Line through both centers for line-circle intersection
    final centerLine = gk.Line(_center1, _center2);
    final lineHits = c1.getLineIntersections(centerLine);

    return Scaffold(
      appBar: AppBar(title: const Text('Circle Intersections')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              intersects
                  ? 'Overlapping — ${points.length} intersection point(s)'
                  : 'Not overlapping',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: _CirclePainter(
                  c1: c1,
                  c2: c2,
                  intersectionPoints: points,
                  tangent: tangent,
                  lineHits: lineHits,
                  centerLine: centerLine,
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

class _CirclePainter extends CustomPainter {
  final gk.Circle c1;
  final gk.Circle c2;
  final List<gk.Point> intersectionPoints;
  final gk.Line? tangent;
  final List<gk.Point> lineHits;
  final gk.Line centerLine;

  _CirclePainter({
    required this.c1,
    required this.c2,
    required this.intersectionPoints,
    this.tangent,
    required this.lineHits,
    required this.centerLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()..style = PaintingStyle.fill;

    // Circle 1
    stroke.color = Colors.indigo;
    fill.color = Colors.indigo.withValues(alpha: 0.08);
    canvas.drawCircle(_off(c1.center), c1.radius, fill);
    canvas.drawCircle(_off(c1.center), c1.radius, stroke);

    // Circle 2
    stroke.color = Colors.teal;
    fill.color = Colors.teal.withValues(alpha: 0.08);
    canvas.drawCircle(_off(c2.center), c2.radius, fill);
    canvas.drawCircle(_off(c2.center), c2.radius, stroke);

    // Center line (dim)
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    canvas.drawLine(_off(centerLine.a), _off(centerLine.b), linePaint);

    // Line-circle intersection points (on c1)
    final lineHitPaint = Paint()..color = Colors.orange;
    for (final p in lineHits) {
      canvas.drawCircle(_off(p), 5, lineHitPaint);
    }

    // Circle-circle intersection points
    final hitPaint = Paint()..color = Colors.red;
    for (final p in intersectionPoints) {
      canvas.drawCircle(_off(p), 7, hitPaint);
      canvas.drawCircle(
        _off(p),
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Tangent line at first intersection
    if (tangent != null) {
      final tPaint = Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      // Extend tangent for visibility
      final extended = tangent!.extend(40);
      canvas.drawLine(_off(extended.a), _off(extended.b), tPaint);
      _drawLabel(canvas, 'tangent', Offset(extended.b.x + 4, extended.b.y - 16),
          Colors.deepOrange);
    }

    // Center dots
    final dotPaint = Paint()..color = Colors.black54;
    canvas.drawCircle(_off(c1.center), 4, dotPaint);
    canvas.drawCircle(_off(c2.center), 4, dotPaint);

    // Distance + diameter labels
    final dist = c1.center.distanceTo(c2.center);
    final mid = gk.Line(c1.center, c2.center).midPoint;
    _drawLabel(canvas, 'd=${dist.toStringAsFixed(0)}',
        Offset(mid.x - 16, mid.y + 6), Colors.black54);
    _drawLabel(canvas, 'ø${c1.diameter.toStringAsFixed(0)}',
        Offset(c1.center.x - 14, c1.center.y - 8), Colors.indigo);
    _drawLabel(canvas, 'ø${c2.diameter.toStringAsFixed(0)}',
        Offset(c2.center.x - 14, c2.center.y - 8), Colors.teal);

    _drawLabel(canvas, 'Drag circles to move',
        Offset(size.width / 2 - 64, size.height - 40), Colors.grey);
  }

  Offset _off(gk.Point p) => Offset(p.x, p.y);

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
  bool shouldRepaint(covariant _CirclePainter old) =>
      c1.center != old.c1.center || c2.center != old.c2.center;
}
