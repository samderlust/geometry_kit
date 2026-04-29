import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class SplineDemo extends StatefulWidget {
  const SplineDemo({super.key});

  @override
  State<SplineDemo> createState() => _SplineDemoState();
}

class _SplineDemoState extends State<SplineDemo> {
  late List<gk.Point> _controlPoints;
  int _dragging = -1;
  int _sampleCount = 80;
  double _tangentT = 0.5;
  bool _initialized = false;

  void _initPoints(double w, double h) {
    if (_initialized) return;
    _initialized = true;
    _controlPoints = [
      gk.Point(40, h * 0.5),
      gk.Point(w * 0.2, h * 0.2),
      gk.Point(w * 0.4, h * 0.7),
      gk.Point(w * 0.6, h * 0.3),
      gk.Point(w * 0.8, h * 0.6),
      gk.Point(w - 40, h * 0.4),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spline')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Text('Samples:'),
                Expanded(
                  child: Slider(
                    min: 10,
                    max: 200,
                    value: _sampleCount.toDouble(),
                    onChanged: (v) => setState(() => _sampleCount = v.round()),
                  ),
                ),
                Text('$_sampleCount'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('Tangent t:'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 1,
                    value: _tangentT,
                    onChanged: (v) => setState(() => _tangentT = v),
                  ),
                ),
                Text(_tangentT.toStringAsFixed(2)),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              _initPoints(constraints.maxWidth, constraints.maxHeight);
              final spline = gk.Spline(_controlPoints);
              return GestureDetector(
                onPanStart: (d) {
                  final tap = gk.Point(
                      d.localPosition.dx, d.localPosition.dy);
                  double minD = 30;
                  for (int i = 0; i < _controlPoints.length; i++) {
                    final dist = _controlPoints[i].distanceTo(tap);
                    if (dist < minD) {
                      minD = dist;
                      _dragging = i;
                    }
                  }
                },
                onPanUpdate: (d) {
                  if (_dragging >= 0) {
                    setState(() {
                      _controlPoints[_dragging] = gk.Point(
                          d.localPosition.dx, d.localPosition.dy);
                    });
                  }
                },
                onPanEnd: (_) => _dragging = -1,
                child: CustomPaint(
                  painter: _SplinePainter(
                    spline: spline,
                    sampleCount: _sampleCount,
                    tangentT: _tangentT,
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

class _SplinePainter extends CustomPainter {
  final gk.Spline spline;
  final int sampleCount;
  final double tangentT;

  _SplinePainter({
    required this.spline,
    required this.sampleCount,
    required this.tangentT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Sample points
    final samples = spline.sample(sampleCount);

    // Draw sampled curve
    final curvePaint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final curvePath = Path();
    curvePath.moveTo(samples.first.x, samples.first.y);
    for (final p in samples.skip(1)) {
      curvePath.lineTo(p.x, p.y);
    }
    canvas.drawPath(curvePath, curvePaint);

    // Control points polygon (guide)
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    for (int i = 0; i < spline.controlPoints.length - 1; i++) {
      final a = spline.controlPoints[i];
      final b = spline.controlPoints[i + 1];
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), guidePaint);
    }

    // Control point handles
    for (int i = 0; i < spline.controlPoints.length; i++) {
      final p = spline.controlPoints[i];
      canvas.drawCircle(Offset(p.x, p.y), 8, Paint()..color = Colors.indigo);
      canvas.drawCircle(
        Offset(p.x, p.y),
        8,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawLabel(canvas, 'P$i', Offset(p.x + 10, p.y - 14), Colors.indigo);
    }

    // Tangent at t
    final maxT = spline.segmentCount.toDouble();
    final actualT = tangentT * maxT;
    final tangentPt = spline.pointAt(actualT);
    final tangentDir = spline.tangentAt(actualT);

    // Draw tangent line
    const tangentLen = 50.0;
    final tStart = gk.Point(
      tangentPt.x - tangentDir.x * tangentLen,
      tangentPt.y - tangentDir.y * tangentLen,
    );
    final tEnd = gk.Point(
      tangentPt.x + tangentDir.x * tangentLen,
      tangentPt.y + tangentDir.y * tangentLen,
    );
    final tangentPaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(tStart.x, tStart.y), Offset(tEnd.x, tEnd.y), tangentPaint);
    canvas.drawCircle(
        Offset(tangentPt.x, tangentPt.y), 6, Paint()..color = Colors.red);
    _drawLabel(canvas, 'tangent', Offset(tEnd.x + 4, tEnd.y - 14),
        Colors.deepOrange);

    // Bounding box
    final bbox = spline.boundingBox(samples: sampleCount);
    final bboxPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(
      Rect.fromPoints(
        Offset(bbox.min.x, bbox.min.y),
        Offset(bbox.max.x, bbox.max.y),
      ),
      bboxPaint,
    );

    // Info
    _drawLabel(
      canvas,
      'length ≈ ${spline.approximateLength(samples: sampleCount).toStringAsFixed(1)}  '
          '${spline.controlPoints.length} ctrl pts  '
          '${spline.segmentCount} segs',
      Offset(16, size.height - 30),
      Colors.black87,
    );
    _drawLabel(canvas, 'Drag control points',
        Offset(size.width / 2 - 56, 8), Colors.grey);
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
  bool shouldRepaint(covariant _SplinePainter old) => true;
}
