import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class BezierDemo extends StatefulWidget {
  const BezierDemo({super.key});

  @override
  State<BezierDemo> createState() => _BezierDemoState();
}

class _BezierDemoState extends State<BezierDemo> {
  // Quadratic control points
  gk.Point _qControl = gk.Point(150, 80);

  // Cubic control points
  gk.Point _cControl1 = gk.Point(100, 380);
  gk.Point _cControl2 = gk.Point(300, 320);

  double _splitT = 0.5;
  int _dragging = 0; // 1=qControl, 2=cControl1, 3=cControl2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bezier Curves')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Text('Split t:'),
                Expanded(
                  child: Slider(
                    min: 0.05,
                    max: 0.95,
                    value: _splitT,
                    onChanged: (v) => setState(() => _splitT = v),
                  ),
                ),
                Text(_splitT.toStringAsFixed(2)),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return GestureDetector(
                onPanStart: (d) {
                  final p = gk.Point(
                      d.localPosition.dx, d.localPosition.dy);
                  final d1 = _qControl.distanceTo(p);
                  final d2 = _cControl1.distanceTo(p);
                  final d3 = _cControl2.distanceTo(p);
                  final minD = [d1, d2, d3].reduce((a, b) => a < b ? a : b);
                  if (minD > 40) return;
                  if (minD == d1) {
                    _dragging = 1;
                  } else if (minD == d2) {
                    _dragging = 2;
                  } else {
                    _dragging = 3;
                  }
                },
                onPanUpdate: (d) {
                  final p = gk.Point(
                      d.localPosition.dx, d.localPosition.dy);
                  setState(() {
                    if (_dragging == 1) _qControl = p;
                    if (_dragging == 2) _cControl1 = p;
                    if (_dragging == 3) _cControl2 = p;
                  });
                },
                onPanEnd: (_) => _dragging = 0,
                child: CustomPaint(
                  painter: _BezierPainter(
                    qControl: _qControl,
                    cControl1: _cControl1,
                    cControl2: _cControl2,
                    splitT: _splitT,
                    width: constraints.maxWidth,
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

class _BezierPainter extends CustomPainter {
  final gk.Point qControl;
  final gk.Point cControl1;
  final gk.Point cControl2;
  final double splitT;
  final double width;

  _BezierPainter({
    required this.qControl,
    required this.cControl1,
    required this.cControl2,
    required this.splitT,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- Quadratic Bezier ---
    final qStart = gk.Point(40, 200);
    final qEnd = gk.Point(width - 40, 200);
    final quad = gk.QuadraticBezier(
        start: qStart, control: qControl, end: qEnd);

    _drawLabel(canvas, 'Quadratic Bezier', const Offset(16, 24), Colors.black87);

    // Control polygon
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    canvas.drawLine(_off(qStart), _off(qControl), guidePaint);
    canvas.drawLine(_off(qControl), _off(qEnd), guidePaint);

    // Curve
    _drawBezierPath(canvas, quad, Colors.indigo);

    // Split visualization
    final splitPt = quad.pointAt(splitT);
    canvas.drawCircle(_off(splitPt), 6, Paint()..color = Colors.red);
    _drawLabel(canvas, 't=${splitT.toStringAsFixed(2)}',
        Offset(splitPt.x + 8, splitPt.y - 16), Colors.red);

    // Bounding box
    final qBbox = quad.boundingBox;
    final bboxPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(
        Rect.fromLTWH(qBbox.x, qBbox.y, qBbox.width, qBbox.height), bboxPaint);

    // Length
    _drawLabel(canvas, 'len=${quad.length.toStringAsFixed(1)}',
        Offset(width - 120, 24), Colors.indigo);

    // Control point handle
    _drawHandle(canvas, qControl, Colors.indigo, 'P1');

    // Endpoints
    canvas.drawCircle(_off(qStart), 4, Paint()..color = Colors.black54);
    canvas.drawCircle(_off(qEnd), 4, Paint()..color = Colors.black54);

    // --- Cubic Bezier ---
    final cStart = gk.Point(40, 480);
    final cEnd = gk.Point(width - 40, 480);
    final cubic = gk.CubicBezier(
        start: cStart, control1: cControl1, control2: cControl2, end: cEnd);

    _drawLabel(
        canvas, 'Cubic Bezier', const Offset(16, 290), Colors.black87);

    // Control polygon
    canvas.drawLine(_off(cStart), _off(cControl1), guidePaint);
    canvas.drawLine(_off(cControl1), _off(cControl2), guidePaint);
    canvas.drawLine(_off(cControl2), _off(cEnd), guidePaint);

    // Curve
    _drawCubicPath(canvas, cubic, Colors.teal);

    // Split
    final cSplitPt = cubic.pointAt(splitT);
    canvas.drawCircle(_off(cSplitPt), 6, Paint()..color = Colors.red);

    // Bounding box
    final cBbox = cubic.boundingBox;
    canvas.drawRect(
        Rect.fromLTWH(cBbox.x, cBbox.y, cBbox.width, cBbox.height), bboxPaint);

    // Length
    _drawLabel(canvas, 'len=${cubic.length.toStringAsFixed(1)}',
        Offset(width - 120, 290), Colors.teal);

    // Control point handles
    _drawHandle(canvas, cControl1, Colors.teal, 'C1');
    _drawHandle(canvas, cControl2, Colors.teal, 'C2');

    // Endpoints
    canvas.drawCircle(_off(cStart), 4, Paint()..color = Colors.black54);
    canvas.drawCircle(_off(cEnd), 4, Paint()..color = Colors.black54);

    _drawLabel(canvas, 'Drag control points',
        Offset(size.width / 2 - 56, size.height - 30), Colors.grey);
  }

  void _drawBezierPath(
      Canvas canvas, gk.QuadraticBezier b, Color color) {
    final path = Path();
    final start = b.pointAt(0);
    path.moveTo(start.x, start.y);
    for (int i = 1; i <= 60; i++) {
      final p = b.pointAt(i / 60);
      path.lineTo(p.x, p.y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawCubicPath(Canvas canvas, gk.CubicBezier b, Color color) {
    final path = Path();
    final start = b.pointAt(0);
    path.moveTo(start.x, start.y);
    for (int i = 1; i <= 60; i++) {
      final p = b.pointAt(i / 60);
      path.lineTo(p.x, p.y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawHandle(Canvas canvas, gk.Point p, Color color, String label) {
    canvas.drawCircle(_off(p), 8, Paint()..color = color);
    canvas.drawCircle(
      _off(p),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawLabel(canvas, label, Offset(p.x + 10, p.y - 16), color);
  }

  Offset _off(gk.Point p) => Offset(p.x, p.y);

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _BezierPainter old) =>
      qControl != old.qControl ||
      cControl1 != old.cControl1 ||
      cControl2 != old.cControl2 ||
      splitT != old.splitT;
}
