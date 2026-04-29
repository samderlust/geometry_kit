import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class EllipseDemo extends StatefulWidget {
  const EllipseDemo({super.key});

  @override
  State<EllipseDemo> createState() => _EllipseDemoState();
}

class _EllipseDemoState extends State<EllipseDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  double _rx = 120;
  double _ry = 70;
  gk.Point? _tapPoint;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ellipse')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Text('rX:'),
                Expanded(
                  child: Slider(
                    min: 40,
                    max: 160,
                    value: _rx,
                    onChanged: (v) => setState(() => _rx = v),
                  ),
                ),
                Text(_rx.toInt().toString()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('rY:'),
                Expanded(
                  child: Slider(
                    min: 30,
                    max: 140,
                    value: _ry,
                    onChanged: (v) => setState(() => _ry = v),
                  ),
                ),
                Text(_ry.toInt().toString()),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: (d) {
                setState(() {
                  _tapPoint = gk.Point(
                    d.localPosition.dx,
                    d.localPosition.dy,
                  );
                });
              },
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _EllipsePainter(
                      rx: _rx,
                      ry: _ry,
                      traceT: _anim.value,
                      tapPoint: _tapPoint,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EllipsePainter extends CustomPainter {
  final double rx;
  final double ry;
  final double traceT;
  final gk.Point? tapPoint;

  _EllipsePainter({
    required this.rx,
    required this.ry,
    required this.traceT,
    this.tapPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = gk.Point(size.width / 2, size.height / 2 - 20);
    final ellipse = gk.Ellipse(center: center, radiusX: rx, radiusY: ry);

    // Draw ellipse
    final stroke = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final rect = Rect.fromCenter(
      center: Offset(center.x, center.y),
      width: rx * 2,
      height: ry * 2,
    );
    canvas.drawOval(rect, fill);
    canvas.drawOval(rect, stroke);

    // Foci
    final foci = ellipse.foci;
    final f1 = foci[0];
    final f2 = foci[1];
    final fociPaint = Paint()..color = Colors.deepOrange;
    canvas.drawCircle(Offset(f1.x, f1.y), 5, fociPaint);
    canvas.drawCircle(Offset(f2.x, f2.y), 5, fociPaint);
    _drawLabel(canvas, 'F₁', Offset(f1.x - 14, f1.y - 18),
        Colors.deepOrange);
    _drawLabel(canvas, 'F₂', Offset(f2.x + 6, f2.y - 18),
        Colors.deepOrange);

    // Trace point moving along ellipse
    final angle = traceT * 2 * math.pi;
    final tracePoint = ellipse.pointAt(angle);
    final tracePaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(tracePoint.x, tracePoint.y), 6, tracePaint);

    // Lines from foci to trace point
    final fociLinePaint = Paint()
      ..color = Colors.deepOrange.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(f1.x, f1.y),
      Offset(tracePoint.x, tracePoint.y),
      fociLinePaint,
    );
    canvas.drawLine(
      Offset(f2.x, f2.y),
      Offset(tracePoint.x, tracePoint.y),
      fociLinePaint,
    );

    // Tap hit test
    if (tapPoint != null) {
      final inside = ellipse.contains(tapPoint!);
      final dotColor = inside ? Colors.green : Colors.red;
      canvas.drawCircle(Offset(tapPoint!.x, tapPoint!.y), 5,
          Paint()..color = dotColor);
      _drawLabel(
        canvas,
        inside ? 'inside' : 'outside',
        Offset(tapPoint!.x + 8, tapPoint!.y - 6),
        dotColor,
      );
    }

    // Info labels
    final infoY = size.height - 80;
    _drawLabel(canvas, 'eccentricity: ${ellipse.eccentricity.toStringAsFixed(3)}',
        Offset(20, infoY), Colors.black87);
    _drawLabel(canvas, 'area: ${ellipse.area.toStringAsFixed(1)}',
        Offset(20, infoY + 18), Colors.black87);
    _drawLabel(
        canvas,
        'perimeter ≈ ${ellipse.perimeter.toStringAsFixed(1)}',
        Offset(20, infoY + 36),
        Colors.black87);
    if (ellipse.isCircle) {
      _drawLabel(canvas, '(is a circle)', Offset(20, infoY + 54), Colors.teal);
    }

    // Center dot
    canvas.drawCircle(Offset(center.x, center.y), 3, Paint()..color = Colors.black54);
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
  bool shouldRepaint(covariant _EllipsePainter old) =>
      rx != old.rx || ry != old.ry || traceT != old.traceT || tapPoint != old.tapPoint;
}
