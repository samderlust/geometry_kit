import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class ShapeDrawingDemo extends StatelessWidget {
  const ShapeDrawingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shape Drawing')),
      body: CustomPaint(
        painter: _ShapePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // --- Hexagon ---
    strokePaint.color = Colors.indigo;
    fillPaint.color = Colors.indigo.withValues(alpha: 0.15);

    final hex = gk.Polygon.regular(
      sides: 6,
      radius: 70,
      center: gk.Point(size.width * 0.3, 120),
    );
    final hexPath = _polygonPath(hex);
    canvas.drawPath(hexPath, fillPaint);
    canvas.drawPath(hexPath, strokePaint);
    _drawLabel(canvas, 'Hexagon', Offset(size.width * 0.3 - 28, 200));

    // --- Circle ---
    strokePaint.color = Colors.teal;
    fillPaint.color = Colors.teal.withValues(alpha: 0.15);

    final circle = gk.Circle(
      radius: 60,
      center: gk.Point(size.width * 0.7, 120),
    );
    canvas.drawCircle(
      Offset(circle.center.x, circle.center.y),
      circle.radius,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(circle.center.x, circle.center.y),
      circle.radius,
      strokePaint,
    );
    _drawLabel(canvas, 'Circle', Offset(size.width * 0.7 - 22, 200));

    // --- Arc ---
    strokePaint.color = Colors.deepOrange;
    strokePaint.strokeWidth = 3;

    final arc = gk.Arc.fromDegrees(
      center: gk.Point(size.width * 0.3, 330),
      radius: 60,
      startDeg: 0,
      endDeg: 270,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(arc.center.x, arc.center.y),
        radius: arc.radius,
      ),
      arc.startAngle,
      arc.sweepAngle,
      false,
      strokePaint,
    );
    _drawLabel(canvas, 'Arc (270°)', Offset(size.width * 0.3 - 34, 410));

    // --- Pentagon ---
    strokePaint.color = Colors.purple;
    strokePaint.strokeWidth = 2;
    fillPaint.color = Colors.purple.withValues(alpha: 0.15);

    final pentagon = gk.Polygon.regular(
      sides: 5,
      radius: 60,
      center: gk.Point(size.width * 0.7, 330),
    );
    final pentPath = _polygonPath(pentagon);
    canvas.drawPath(pentPath, fillPaint);
    canvas.drawPath(pentPath, strokePaint);
    _drawLabel(canvas, 'Pentagon', Offset(size.width * 0.7 - 30, 410));

    // --- Triangle ---
    strokePaint.color = Colors.green;
    fillPaint.color = Colors.green.withValues(alpha: 0.15);

    final tri = gk.Polygon.regular(
      sides: 3,
      radius: 60,
      center: gk.Point(size.width * 0.5, 540),
    );
    final triPath = _polygonPath(tri);
    canvas.drawPath(triPath, fillPaint);
    canvas.drawPath(triPath, strokePaint);
    _drawLabel(canvas, 'Triangle', Offset(size.width * 0.5 - 28, 620));
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

  void _drawLabel(Canvas canvas, String text, Offset position) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
