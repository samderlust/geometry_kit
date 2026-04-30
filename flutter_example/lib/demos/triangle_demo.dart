import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class TriangleDemo extends StatefulWidget {
  const TriangleDemo({super.key});

  @override
  State<TriangleDemo> createState() => _TriangleDemoState();
}

enum _TriPreset { equilateral, right, isosceles, scalene, obtuse }

class _TriangleDemoState extends State<TriangleDemo> {
  _TriPreset _preset = _TriPreset.equilateral;
  gk.Point? _tapPoint;
  bool _showCircumcircle = true;
  bool _showIncircle = true;

  gk.Triangle _buildTriangle(double cx, double cy) {
    switch (_preset) {
      case _TriPreset.equilateral:
        return gk.Triangle.equilateral(
            center: gk.Point(cx, cy), radius: 100);
      case _TriPreset.right:
        return gk.Triangle(
          gk.Point(cx - 80, cy + 60),
          gk.Point(cx + 80, cy + 60),
          gk.Point(cx - 80, cy - 80),
        );
      case _TriPreset.isosceles:
        return gk.Triangle(
          gk.Point(cx - 70, cy + 60),
          gk.Point(cx + 70, cy + 60),
          gk.Point(cx, cy - 90),
        );
      case _TriPreset.scalene:
        return gk.Triangle(
          gk.Point(cx - 90, cy + 50),
          gk.Point(cx + 80, cy + 50),
          gk.Point(cx + 20, cy - 80),
        );
      case _TriPreset.obtuse:
        return gk.Triangle(
          gk.Point(cx - 100, cy + 40),
          gk.Point(cx + 100, cy + 40),
          gk.Point(cx + 60, cy - 30),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Triangle')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _TriPreset.values.map((p) {
                final label = p.name[0].toUpperCase() + p.name.substring(1);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: _preset == p,
                    onSelected: (_) => setState(() {
                      _preset = p;
                      _tapPoint = null;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Circumcircle'),
                  selected: _showCircumcircle,
                  onSelected: (v) => setState(() => _showCircumcircle = v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Incircle'),
                  selected: _showIncircle,
                  onSelected: (v) => setState(() => _showIncircle = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final cx = constraints.maxWidth / 2;
              final cy = constraints.maxHeight / 2 - 10;
              final tri = _buildTriangle(cx, cy);
              return GestureDetector(
                onTapDown: (d) {
                  setState(() {
                    _tapPoint = gk.Point(
                        d.localPosition.dx, d.localPosition.dy);
                  });
                },
                child: CustomPaint(
                  painter: _TrianglePainter(
                    tri: tri,
                    tapPoint: _tapPoint,
                    showCircumcircle: _showCircumcircle,
                    showIncircle: _showIncircle,
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

class _TrianglePainter extends CustomPainter {
  final gk.Triangle tri;
  final gk.Point? tapPoint;
  final bool showCircumcircle;
  final bool showIncircle;

  _TrianglePainter({
    required this.tri,
    this.tapPoint,
    required this.showCircumcircle,
    required this.showIncircle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Triangle fill + stroke
    final fill = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(tri.a.x, tri.a.y)
      ..lineTo(tri.b.x, tri.b.y)
      ..lineTo(tri.c.x, tri.c.y)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Vertices
    final dotPaint = Paint()..color = Colors.indigo;
    for (final v in [tri.a, tri.b, tri.c]) {
      canvas.drawCircle(Offset(v.x, v.y), 4, dotPaint);
    }
    _drawLabel(canvas, 'A', Offset(tri.a.x - 16, tri.a.y - 4), Colors.indigo);
    _drawLabel(canvas, 'B', Offset(tri.b.x + 6, tri.b.y - 4), Colors.indigo);
    _drawLabel(canvas, 'C', Offset(tri.c.x + 6, tri.c.y - 16), Colors.indigo);

    // Circumscribed circle
    if (showCircumcircle) {
      final cc = tri.circumscribedCircle;
      final ccPaint = Paint()
        ..color = Colors.teal.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(
          Offset(cc.center.x, cc.center.y), cc.radius, ccPaint);
      canvas.drawCircle(Offset(cc.center.x, cc.center.y), 4,
          Paint()..color = Colors.teal);
      _drawLabel(canvas, 'circumcenter',
          Offset(cc.center.x + 6, cc.center.y + 6), Colors.teal);
    }

    // Inscribed circle
    if (showIncircle) {
      final ic = tri.inscribedCircle;
      final icPaint = Paint()
        ..color = Colors.deepOrange.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(
          Offset(ic.center.x, ic.center.y), ic.radius, icPaint);
      canvas.drawCircle(Offset(ic.center.x, ic.center.y), 4,
          Paint()..color = Colors.deepOrange);
      _drawLabel(canvas, 'incenter',
          Offset(ic.center.x + 6, ic.center.y - 16), Colors.deepOrange);
    }

    // Centroid
    final centroid = tri.centroid;
    canvas.drawCircle(
        Offset(centroid.x, centroid.y), 5, Paint()..color = Colors.red);
    _drawLabel(canvas, 'centroid',
        Offset(centroid.x + 8, centroid.y - 4), Colors.red);

    // Hypotenuse highlight
    final hyp = tri.hypotenuse;
    final hypPaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.6)
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(hyp.a.x, hyp.a.y), Offset(hyp.b.x, hyp.b.y), hypPaint);
    final hypMid = hyp.midPoint;
    _drawLabel(canvas, 'hyp=${hyp.length.toStringAsFixed(1)}',
        Offset(hypMid.x + 4, hypMid.y - 18), Colors.purple);

    // Hit test
    if (tapPoint != null) {
      final inside = tri.contains(tapPoint!);
      final col = inside ? Colors.green : Colors.red;
      canvas.drawCircle(
          Offset(tapPoint!.x, tapPoint!.y), 5, Paint()..color = col);
      _drawLabel(canvas, inside ? 'inside' : 'outside',
          Offset(tapPoint!.x + 8, tapPoint!.y - 6), col);
    }

    // Classification
    final types = <String>[];
    if (tri.isEquilateral) types.add('equilateral');
    if (tri.isIsosceles && !tri.isEquilateral) types.add('isosceles');
    if (tri.isScalene) types.add('scalene');
    if (tri.isRightTriangle) types.add('right');
    if (tri.isAcute) types.add('acute');
    if (tri.isObtuse) types.add('obtuse');

    final infoY = size.height - 80;
    _drawLabel(canvas, 'Type: ${types.join(", ")}',
        Offset(16, infoY), Colors.black87);
    _drawLabel(canvas, 'area: ${tri.area.abs().toStringAsFixed(1)}  '
        'perimeter: ${tri.perimeter.toStringAsFixed(1)}',
        Offset(16, infoY + 18), Colors.black87);
    _drawLabel(canvas, 'height: ${tri.height.toStringAsFixed(1)}',
        Offset(16, infoY + 36), Colors.black87);
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
  bool shouldRepaint(covariant _TrianglePainter old) =>
      tri != old.tri ||
      tapPoint != old.tapPoint ||
      showCircumcircle != old.showCircumcircle ||
      showIncircle != old.showIncircle;
}
