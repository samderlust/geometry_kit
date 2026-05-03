import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class MeasurementDemo extends StatefulWidget {
  const MeasurementDemo({super.key});

  @override
  State<MeasurementDemo> createState() => _MeasurementDemoState();
}

class _MeasurementDemoState extends State<MeasurementDemo> {
  gk.Point _dragPoint = gk.Point(300, 150);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Measurements')),
      body: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _dragPoint = gk.Point(
              d.localPosition.dx,
              d.localPosition.dy,
            );
          });
        },
        child: CustomPaint(
          painter: _MeasurementPainter(dragPoint: _dragPoint),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _MeasurementPainter extends CustomPainter {
  final gk.Point dragPoint;

  _MeasurementPainter({required this.dragPoint});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = gk.Point(60, size.height * 0.5);

    // Line from fixed origin to draggable point
    final line1 = gk.Line(origin, dragPoint);

    // Horizontal reference line
    final line2 = gk.Line(origin, gk.Point(size.width - 40, origin.y));

    final linePaint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final refPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw reference line (dashed-like via path effect)
    canvas.drawLine(
      Offset(line2.a.x, line2.a.y),
      Offset(line2.b.x, line2.b.y),
      refPaint,
    );

    // Draw main line
    canvas.drawLine(
      Offset(line1.a.x, line1.a.y),
      Offset(line1.b.x, line1.b.y),
      linePaint,
    );

    // Draggable endpoint indicator
    final dotPaint = Paint()..color = Colors.indigo;
    canvas.drawCircle(Offset(dragPoint.x, dragPoint.y), 8, dotPaint);
    canvas.drawCircle(
      Offset(dragPoint.x, dragPoint.y),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Origin dot
    canvas.drawCircle(Offset(origin.x, origin.y), 5, dotPaint);

    // --- Length annotation ---
    final mid = line1.midPoint;
    _drawLabel(
      canvas,
      '${line1.length.toStringAsFixed(1)} px',
      Offset(mid.x - 30, mid.y - 24),
      Colors.indigo,
    );

    // --- Angle annotation ---
    final angle = line1.innerAngleWith(line2);
    final angleDeg = angle.toDeg;

    // Draw angle arc
    final arcPaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const arcRadius = 40.0;
    // Determine sweep direction based on drag point position
    final startAngle = dragPoint.y < origin.y ? -angleDeg * math.pi / 180 : 0.0;
    final sweepAngle = angleDeg * math.pi / 180;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(origin.x, origin.y), radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    _drawLabel(
      canvas,
      '${angleDeg.toStringAsFixed(1)}°',
      Offset(origin.x + arcRadius + 4, origin.y - 10),
      Colors.deepOrange,
    );

    // --- Hint ---
    _drawLabel(
      canvas,
      'Drag the endpoint',
      Offset(size.width / 2 - 50, 20),
      Colors.grey,
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _MeasurementPainter old) =>
      dragPoint != old.dragPoint;
}
