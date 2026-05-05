import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class RectangleDemo extends StatefulWidget {
  const RectangleDemo({super.key});

  @override
  State<RectangleDemo> createState() => _RectangleDemoState();
}

class _RectangleDemoState extends State<RectangleDemo> {
  gk.Point _center1 = gk.Point(140, 260);
  gk.Point _center2 = gk.Point(260, 300);
  gk.Point? _tapPoint;
  int _dragging = 0;

  static const _w1 = 160.0, _h1 = 120.0;
  static const _w2 = 120.0, _h2 = 120.0;

  gk.Rectangle get _r1 =>
      gk.Rectangle.fromCenter(center: _center1, width: _w1, height: _h1);
  gk.Rectangle get _r2 =>
      gk.Rectangle.fromCenter(center: _center2, width: _w2, height: _h2);

  void _onPanStart(DragStartDetails d) {
    final p = gk.Point(d.localPosition.dx, d.localPosition.dy);
    if (_r1.contains(p)) {
      _dragging = 1;
    } else if (_r2.contains(p)) {
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

  void _onTapDown(TapDownDetails d) {
    setState(() {
      _tapPoint = gk.Point(d.localPosition.dx, d.localPosition.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r1 = _r1;
    final r2 = _r2;
    final overlaps = r1.overlaps(r2);

    String status = overlaps ? 'Rectangles overlap!' : 'No overlap';
    if (_tapPoint != null) {
      final in1 = r1.contains(_tapPoint!);
      final in2 = r2.contains(_tapPoint!);
      if (in1 || in2) {
        status += ' • Tap inside ${in1 ? "blue" : ""}${in1 && in2 ? " & " : ""}${in2 ? "green" : ""}';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rectangle')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(status, style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTapDown: _onTapDown,
              child: CustomPaint(
                painter: _RectPainter(
                  r1: r1,
                  r2: r2,
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

class _RectPainter extends CustomPainter {
  final gk.Rectangle r1;
  final gk.Rectangle r2;
  final gk.Point? tapPoint;

  _RectPainter({required this.r1, required this.r2, this.tapPoint});

  @override
  void paint(Canvas canvas, Size size) {
    final overlaps = r1.overlaps(r2);

    // Rectangle 1
    _drawRect(canvas, r1, Colors.indigo, overlaps);
    // Rectangle 2
    _drawRect(canvas, r2, Colors.green, overlaps);

    // Diagonal of r1
    final diagPaint = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(r1.topLeft.x, r1.topLeft.y),
      Offset(r1.bottomRight.x, r1.bottomRight.y),
      diagPaint,
    );
    _drawLabel(
      canvas,
      'diag=${r1.diagonal.toStringAsFixed(1)}',
      Offset(r1.center.x - 36, r1.center.y - 24),
      Colors.indigo,
    );

    // isSquare label for r2
    _drawLabel(
      canvas,
      r2.isSquare ? 'square ✓' : '${r2.width.toInt()}×${r2.height.toInt()}',
      Offset(r2.center.x - 24, r2.center.y - 8),
      Colors.green,
    );

    // Corner vertices of r1
    final dotPaint = Paint()..color = Colors.indigo;
    for (final v in r1.vertices) {
      canvas.drawCircle(Offset(v.x, v.y), 3, dotPaint);
    }

    // Tap point
    if (tapPoint != null) {
      final tp = Paint()..color = Colors.red;
      canvas.drawCircle(Offset(tapPoint!.x, tapPoint!.y), 5, tp);
    }

    _drawLabel(canvas, 'Drag rectangles • Tap to hit-test',
        Offset(size.width / 2 - 100, size.height - 40), Colors.grey);
  }

  void _drawRect(
      Canvas canvas, gk.Rectangle r, Color color, bool overlapping) {
    final fill = Paint()
      ..color = color.withValues(alpha: overlapping ? 0.2 : 0.1)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Rect.fromLTWH(r.x, r.y, r.width, r.height);
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, stroke);
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
  bool shouldRepaint(covariant _RectPainter old) =>
      r1.center != old.r1.center ||
      r2.center != old.r2.center ||
      tapPoint != old.tapPoint;
}
