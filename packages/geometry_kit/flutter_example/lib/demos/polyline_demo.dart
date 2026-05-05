import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class PolylineDemo extends StatefulWidget {
  const PolylineDemo({super.key});

  @override
  State<PolylineDemo> createState() => _PolylineDemoState();
}

class _PolylineDemoState extends State<PolylineDemo> {
  double _tolerance = 15;
  double _pointAtT = 0.5;
  final List<gk.Point> _points = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_points.isEmpty) {
      // Generate a zigzag path with noise
      final w = MediaQuery.of(context).size.width;
      final rng = math.Random(42);
      for (int i = 0; i < 20; i++) {
        final x = 30 + (w - 60) * i / 19;
        final baseY = 200 + 80 * math.sin(i * 0.7);
        final noise = rng.nextDouble() * 40 - 20;
        _points.add(gk.Point(x, baseY + noise));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final polyline = gk.Polyline(_points);
    final simplified = polyline.simplify(_tolerance);

    return Scaffold(
      appBar: AppBar(title: const Text('Polyline')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Text('Simplify:'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 60,
                    value: _tolerance,
                    onChanged: (v) => setState(() => _tolerance = v),
                  ),
                ),
                Text('ε=${_tolerance.toInt()}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('pointAt:'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 1,
                    value: _pointAtT,
                    onChanged: (v) => setState(() => _pointAtT = v),
                  ),
                ),
                Text('t=${_pointAtT.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Text(
              'Original: ${polyline.points.length} pts, ${polyline.segmentCount} segs  →  '
              'Simplified: ${simplified.points.length} pts',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: _PolylinePainter(
                original: polyline,
                simplified: simplified,
                pointAtT: _pointAtT,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolylinePainter extends CustomPainter {
  final gk.Polyline original;
  final gk.Polyline simplified;
  final double pointAtT;

  _PolylinePainter({
    required this.original,
    required this.simplified,
    required this.pointAtT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Original polyline (dimmed)
    final origPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    _drawPolyline(canvas, original, origPaint);

    // Original points
    final origDot = Paint()..color = Colors.grey.shade400;
    for (final p in original.points) {
      canvas.drawCircle(Offset(p.x, p.y), 3, origDot);
    }

    // Simplified polyline
    final simpPaint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    _drawPolyline(canvas, simplified, simpPaint);

    // Simplified points
    final simpDot = Paint()..color = Colors.indigo;
    for (final p in simplified.points) {
      canvas.drawCircle(Offset(p.x, p.y), 5, simpDot);
    }

    // Bounding box
    final bbox = original.boundingBox;
    final bboxPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(
        Rect.fromLTWH(bbox.x, bbox.y, bbox.width, bbox.height), bboxPaint);

    // pointAt
    final ptAt = original.pointAt(pointAtT);
    canvas.drawCircle(Offset(ptAt.x, ptAt.y), 7, Paint()..color = Colors.red);
    _drawLabel(canvas, 'pointAt(${pointAtT.toStringAsFixed(2)})',
        Offset(ptAt.x + 10, ptAt.y - 16), Colors.red);

    // Length
    _drawLabel(canvas, 'length: ${original.length.toStringAsFixed(1)}',
        Offset(16, size.height - 40), Colors.black87);
  }

  void _drawPolyline(Canvas canvas, gk.Polyline pl, Paint paint) {
    if (pl.points.length < 2) return;
    final path = Path();
    path.moveTo(pl.points.first.x, pl.points.first.y);
    for (final p in pl.points.skip(1)) {
      path.lineTo(p.x, p.y);
    }
    canvas.drawPath(path, paint);
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
  bool shouldRepaint(covariant _PolylinePainter old) =>
      original != old.original ||
      simplified != old.simplified ||
      pointAtT != old.pointAtT;
}
