import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class RingDemo extends StatefulWidget {
  const RingDemo({super.key});

  @override
  State<RingDemo> createState() => _RingDemoState();
}

class _RingDemoState extends State<RingDemo> {
  double _inner = 50;
  double _outer = 110;
  gk.Point? _tapPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ring / Annulus')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Text('Inner r:'),
                Expanded(
                  child: Slider(
                    min: 10,
                    max: _outer - 5,
                    value: _inner.clamp(10, _outer - 5),
                    onChanged: (v) => setState(() => _inner = v),
                  ),
                ),
                Text(_inner.toInt().toString()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('Outer r:'),
                Expanded(
                  child: Slider(
                    min: _inner + 5,
                    max: 160,
                    value: _outer.clamp(_inner + 5, 160),
                    onChanged: (v) => setState(() => _outer = v),
                  ),
                ),
                Text(_outer.toInt().toString()),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final center =
                  gk.Point(constraints.maxWidth / 2, constraints.maxHeight / 2);
              final ring = gk.Ring(
                center: center,
                innerRadius: _inner,
                outerRadius: _outer,
              );
              return GestureDetector(
                onTapDown: (d) {
                  setState(() {
                    _tapPoint = gk.Point(
                        d.localPosition.dx, d.localPosition.dy);
                  });
                },
                child: CustomPaint(
                  painter: _RingPainter(ring: ring, tapPoint: _tapPoint),
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

class _RingPainter extends CustomPainter {
  final gk.Ring ring;
  final gk.Point? tapPoint;

  _RingPainter({required this.ring, this.tapPoint});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(ring.center.x, ring.center.y);

    // Outer circle fill
    final outerFill = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, ring.outerRadius, outerFill);

    // Inner circle (cut out — draw white fill)
    final innerFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(c, ring.innerRadius, innerFill);

    // Strokes
    final outerStroke = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(c, ring.outerRadius, outerStroke);

    final innerStroke = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(c, ring.innerRadius, innerStroke);

    // Width annotation
    final widthStart = Offset(c.dx + ring.innerRadius, c.dy);
    final widthEnd = Offset(c.dx + ring.outerRadius, c.dy);
    final dimPaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 1.5;
    canvas.drawLine(widthStart, widthEnd, dimPaint);
    canvas.drawCircle(widthStart, 3, Paint()..color = Colors.deepOrange);
    canvas.drawCircle(widthEnd, 3, Paint()..color = Colors.deepOrange);
    _drawLabel(canvas, 'w=${ring.width.toStringAsFixed(1)}',
        Offset(widthEnd.dx + 6, widthEnd.dy - 8), Colors.deepOrange);

    // Average radius circle (dimmed)
    final avgPaint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(c, ring.averageRadius, avgPaint);
    _drawLabel(canvas, 'avg r=${ring.averageRadius.toStringAsFixed(1)}',
        Offset(c.dx - ring.averageRadius - 10, c.dy - 16), Colors.teal);

    // Center
    canvas.drawCircle(c, 3, Paint()..color = Colors.red);

    // Hit test
    if (tapPoint != null) {
      final inside = ring.contains(tapPoint!);
      final col = inside ? Colors.green : Colors.red;
      canvas.drawCircle(
          Offset(tapPoint!.x, tapPoint!.y), 5, Paint()..color = col);
      _drawLabel(canvas, inside ? 'in ring' : 'outside',
          Offset(tapPoint!.x + 8, tapPoint!.y - 6), col);
    }

    // Info
    final infoY = size.height - 80;
    _drawLabel(canvas, 'area: ${ring.area.toStringAsFixed(1)}',
        Offset(16, infoY), Colors.black87);
    _drawLabel(
        canvas,
        'outer circ: ${ring.outerCircumference.toStringAsFixed(1)}  '
            'inner circ: ${ring.innerCircumference.toStringAsFixed(1)}',
        Offset(16, infoY + 18),
        Colors.black87);
    _drawLabel(canvas, 'Tap to hit-test',
        Offset(16, infoY + 40), Colors.grey);
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
  bool shouldRepaint(covariant _RingPainter old) =>
      ring != old.ring || tapPoint != old.tapPoint;
}
