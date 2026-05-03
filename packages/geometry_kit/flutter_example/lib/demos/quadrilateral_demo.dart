import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class QuadrilateralDemo extends StatefulWidget {
  const QuadrilateralDemo({super.key});

  @override
  State<QuadrilateralDemo> createState() => _QuadrilateralDemoState();
}

enum _QuadPreset { square, rectangle, rhombus, parallelogram, trapezoid, kite, irregular }

class _QuadrilateralDemoState extends State<QuadrilateralDemo> {
  _QuadPreset _preset = _QuadPreset.square;
  gk.Point? _tapPoint;

  gk.Quadrilateral _buildQuad(double cx, double cy) {
    switch (_preset) {
      case _QuadPreset.square:
        return gk.Quadrilateral(
          gk.Point(cx - 70, cy - 70), gk.Point(cx + 70, cy - 70),
          gk.Point(cx + 70, cy + 70), gk.Point(cx - 70, cy + 70),
        );
      case _QuadPreset.rectangle:
        return gk.Quadrilateral(
          gk.Point(cx - 110, cy - 60), gk.Point(cx + 110, cy - 60),
          gk.Point(cx + 110, cy + 60), gk.Point(cx - 110, cy + 60),
        );
      case _QuadPreset.rhombus:
        return gk.Quadrilateral(
          gk.Point(cx, cy - 90), gk.Point(cx + 70, cy),
          gk.Point(cx, cy + 90), gk.Point(cx - 70, cy),
        );
      case _QuadPreset.parallelogram:
        return gk.Quadrilateral(
          gk.Point(cx - 60, cy - 60), gk.Point(cx + 100, cy - 60),
          gk.Point(cx + 60, cy + 60), gk.Point(cx - 100, cy + 60),
        );
      case _QuadPreset.trapezoid:
        return gk.Quadrilateral(
          gk.Point(cx - 50, cy - 70), gk.Point(cx + 50, cy - 70),
          gk.Point(cx + 100, cy + 70), gk.Point(cx - 100, cy + 70),
        );
      case _QuadPreset.kite:
        return gk.Quadrilateral(
          gk.Point(cx, cy - 100), gk.Point(cx + 60, cy - 20),
          gk.Point(cx, cy + 80), gk.Point(cx - 60, cy - 20),
        );
      case _QuadPreset.irregular:
        return gk.Quadrilateral(
          gk.Point(cx - 80, cy - 50), gk.Point(cx + 60, cy - 80),
          gk.Point(cx + 90, cy + 40), gk.Point(cx - 40, cy + 70),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quadrilateral')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _QuadPreset.values.map((p) {
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
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final cx = constraints.maxWidth / 2;
              final cy = constraints.maxHeight / 2 - 20;
              final quad = _buildQuad(cx, cy);
              return GestureDetector(
                onTapDown: (d) {
                  setState(() {
                    _tapPoint = gk.Point(
                        d.localPosition.dx, d.localPosition.dy);
                  });
                },
                child: CustomPaint(
                  painter: _QuadPainter(quad: quad, tapPoint: _tapPoint),
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

class _QuadPainter extends CustomPainter {
  final gk.Quadrilateral quad;
  final gk.Point? tapPoint;

  _QuadPainter({required this.quad, this.tapPoint});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill + stroke
    final fill = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(quad.a.x, quad.a.y)
      ..lineTo(quad.b.x, quad.b.y)
      ..lineTo(quad.c.x, quad.c.y)
      ..lineTo(quad.d.x, quad.d.y)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Vertices
    final dotPaint = Paint()..color = Colors.indigo;
    final verts = [quad.a, quad.b, quad.c, quad.d];
    final labels = ['A', 'B', 'C', 'D'];
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(verts[i].x, verts[i].y), 4, dotPaint);
      _drawLabel(canvas, labels[i],
          Offset(verts[i].x + 6, verts[i].y - 16), Colors.indigo);
    }

    // Diagonals
    final diagPaint = Paint()
      ..color = Colors.deepOrange.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(quad.a.x, quad.a.y), Offset(quad.c.x, quad.c.y), diagPaint);
    canvas.drawLine(
        Offset(quad.b.x, quad.b.y), Offset(quad.d.x, quad.d.y), diagPaint);

    // Center
    final c = quad.center;
    canvas.drawCircle(Offset(c.x, c.y), 4, Paint()..color = Colors.red);

    // Hit test
    if (tapPoint != null) {
      final inside = quad.contains(tapPoint!);
      final col = inside ? Colors.green : Colors.red;
      canvas.drawCircle(
          Offset(tapPoint!.x, tapPoint!.y), 5, Paint()..color = col);
      _drawLabel(canvas, inside ? 'inside' : 'outside',
          Offset(tapPoint!.x + 8, tapPoint!.y - 6), col);
    }

    // Classification info
    final props = <String>[];
    if (quad.isSquare) props.add('square');
    if (quad.isRectangle && !quad.isSquare) props.add('rectangle');
    if (quad.isRhombus && !quad.isSquare) props.add('rhombus');
    if (quad.isParallelogram &&
        !quad.isRectangle &&
        !quad.isRhombus) {
      props.add('parallelogram');
    }
    if (quad.isTrapezoid && !quad.isParallelogram) props.add('trapezoid');
    if (quad.isKite && !quad.isRhombus) props.add('kite');
    if (props.isEmpty) props.add('irregular');

    final infoY = size.height - 100;
    _drawLabel(canvas, 'Type: ${props.join(", ")}',
        Offset(16, infoY), Colors.black87);
    _drawLabel(canvas, 'convex: ${quad.isConvex ? "yes" : "no"}',
        Offset(16, infoY + 18), quad.isConvex ? Colors.green : Colors.red);
    _drawLabel(canvas, 'area: ${quad.area.toStringAsFixed(1)}',
        Offset(16, infoY + 36), Colors.black87);
    _drawLabel(canvas, 'perimeter: ${quad.perimeter.toStringAsFixed(1)}',
        Offset(16, infoY + 54), Colors.black87);
    _drawLabel(canvas, 'Tap to hit-test',
        Offset(16, infoY + 76), Colors.grey);
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
  bool shouldRepaint(covariant _QuadPainter old) =>
      quad != old.quad || tapPoint != old.tapPoint;
}
