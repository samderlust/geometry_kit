import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class LineToolsDemo extends StatefulWidget {
  const LineToolsDemo({super.key});

  @override
  State<LineToolsDemo> createState() => _LineToolsDemoState();
}

class _LineToolsDemoState extends State<LineToolsDemo> {
  double _lerpT = 0.5;
  double _extendAmt = 30;
  gk.Point _dragPoint = gk.Point(250, 120);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Line Tools')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Text('lerp t:'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 1,
                    value: _lerpT,
                    onChanged: (v) => setState(() => _lerpT = v),
                  ),
                ),
                Text(_lerpT.toStringAsFixed(2)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('extend:'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 80,
                    value: _extendAmt,
                    onChanged: (v) => setState(() => _extendAmt = v),
                  ),
                ),
                Text('${_extendAmt.toInt()}px'),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (d) {
                setState(() {
                  _dragPoint = gk.Point(
                    d.localPosition.dx,
                    d.localPosition.dy,
                  );
                });
              },
              child: CustomPaint(
                painter: _LineToolsPainter(
                  lerpT: _lerpT,
                  extendAmt: _extendAmt,
                  freePoint: _dragPoint,
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

class _LineToolsPainter extends CustomPainter {
  final double lerpT;
  final double extendAmt;
  final gk.Point freePoint;

  _LineToolsPainter({
    required this.lerpT,
    required this.extendAmt,
    required this.freePoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lineA = gk.Point(60, size.height * 0.35);
    final lineB = gk.Point(size.width - 60, size.height * 0.35);
    final mainLine = gk.Line(lineA, lineB);

    // Second line for parallel/perp check
    final line2 = gk.Line(gk.Point(60, size.height * 0.65), freePoint);

    final mainPaint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 2.5;
    // --- Extended line (behind main) ---
    final extended = mainLine.extend(extendAmt);
    final extPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.5)
      ..strokeWidth = 4;
    canvas.drawLine(_off(extended.a), _off(extended.b), extPaint);

    // Main line
    canvas.drawLine(_off(mainLine.a), _off(mainLine.b), mainPaint);

    // Endpoints
    final dotPaint = Paint()..color = Colors.indigo;
    canvas.drawCircle(_off(mainLine.a), 5, dotPaint);
    canvas.drawCircle(_off(mainLine.b), 5, dotPaint);

    // --- Lerp point ---
    final lerpPoint = mainLine.lerp(lerpT);
    final lerpPaint = Paint()..color = Colors.red;
    canvas.drawCircle(_off(lerpPoint), 7, lerpPaint);
    _drawLabel(canvas, 'lerp(${lerpT.toStringAsFixed(2)})',
        Offset(lerpPoint.x - 28, lerpPoint.y - 22), Colors.red);

    // --- Midpoint ---
    final mid = mainLine.midPoint;
    canvas.drawCircle(
        _off(mid), 4, Paint()..color = Colors.purple.withValues(alpha: 0.5));
    _drawLabel(canvas, 'mid', Offset(mid.x - 10, mid.y + 10), Colors.purple);

    // --- Project free point onto main line ---
    final proj = mainLine.projectPoint(freePoint);
    final projPaint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 1.5;
    // Dashed-like connection from free point to projection
    canvas.drawLine(_off(freePoint), _off(proj), projPaint);
    canvas.drawCircle(_off(proj), 6, Paint()..color = Colors.teal);
    canvas.drawCircle(_off(freePoint), 6, Paint()..color = Colors.teal.withValues(alpha: 0.5));
    _drawLabel(canvas, 'projection', Offset(proj.x - 28, proj.y + 10), Colors.teal);
    _drawLabel(canvas, 'drag me', Offset(freePoint.x + 8, freePoint.y - 6),
        Colors.teal);

    // Distance from point to line
    final dist = mainLine.distanceFromAPoint(freePoint);
    final distMid = gk.Point(
      (freePoint.x + proj.x) / 2,
      (freePoint.y + proj.y) / 2,
    );
    _drawLabel(canvas, '${dist.toStringAsFixed(1)}px',
        Offset(distMid.x + 6, distMid.y - 8), Colors.teal);

    // --- Second line ---
    final line2Paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;
    canvas.drawLine(_off(line2.a), _off(line2.b), line2Paint);
    canvas.drawCircle(_off(line2.a), 4, Paint()..color = Colors.green);
    canvas.drawCircle(_off(line2.b), 4, Paint()..color = Colors.green);

    // Parallel / perpendicular checks
    final parallel = mainLine.isParallelTo(line2);
    final perp = mainLine.isPerpendicularTo(line2);
    String relation = 'neither ∥ nor ⊥';
    Color relColor = Colors.black54;
    if (parallel) {
      relation = 'parallel ∥';
      relColor = Colors.green;
    } else if (perp) {
      relation = 'perpendicular ⊥';
      relColor = Colors.deepPurple;
    }
    _drawLabel(canvas, relation, Offset(20, size.height - 40), relColor);

    // Extend label
    if (extendAmt > 0) {
      _drawLabel(canvas, 'extend +${extendAmt.toInt()}px each end',
          Offset(extended.a.x, extended.a.y + 14), Colors.orange);
    }

    // isVertical / isHorizontal
    final props = <String>[];
    if (mainLine.isHorizontal) props.add('horizontal');
    if (mainLine.isVertical) props.add('vertical');
    if (props.isNotEmpty) {
      _drawLabel(canvas, props.join(', '),
          Offset(mainLine.a.x, mainLine.a.y - 22), Colors.indigo);
    }
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
  bool shouldRepaint(covariant _LineToolsPainter old) =>
      lerpT != old.lerpT ||
      extendAmt != old.extendAmt ||
      freePoint != old.freePoint;
}
