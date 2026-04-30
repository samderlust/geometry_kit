import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class CapsuleDemo extends StatefulWidget {
  const CapsuleDemo({super.key});

  @override
  State<CapsuleDemo> createState() => _CapsuleDemoState();
}

class _CapsuleDemoState extends State<CapsuleDemo> {
  double _width = 220;
  double _height = 90;
  gk.Point? _tapPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capsule')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Text('W:'),
                Expanded(
                  child: Slider(
                    min: 60,
                    max: 300,
                    value: _width,
                    onChanged: (v) => setState(() => _width = v),
                  ),
                ),
                Text(_width.toInt().toString()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('H:'),
                Expanded(
                  child: Slider(
                    min: 40,
                    max: 250,
                    value: _height,
                    onChanged: (v) => setState(() => _height = v),
                  ),
                ),
                Text(_height.toInt().toString()),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (d) {
                  setState(() {
                    _tapPoint = gk.Point(
                        d.localPosition.dx, d.localPosition.dy);
                  });
                },
                child: CustomPaint(
                  painter: _CapsulePainter(
                    capsuleWidth: _width,
                    capsuleHeight: _height,
                    canvasWidth: constraints.maxWidth,
                    canvasHeight: constraints.maxHeight,
                    tapPoint: _tapPoint,
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

class _CapsulePainter extends CustomPainter {
  final double capsuleWidth;
  final double capsuleHeight;
  final double canvasWidth;
  final double canvasHeight;
  final gk.Point? tapPoint;

  _CapsulePainter({
    required this.capsuleWidth,
    required this.capsuleHeight,
    required this.canvasWidth,
    required this.canvasHeight,
    this.tapPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = gk.Point(canvasWidth / 2, canvasHeight / 2 - 20);
    final capsule = gk.Capsule.fromRect(
      center: center,
      width: capsuleWidth,
      height: capsuleHeight,
    );

    // Draw capsule shape using end caps + rectangle body
    final axisA = capsule.medialAxis.a;
    final axisB = capsule.medialAxis.b;
    final r = capsule.radius;

    // Build capsule path
    final path = Path();
    if (capsuleWidth >= capsuleHeight) {
      // Horizontal capsule
      path.addArc(
        Rect.fromCircle(center: Offset(axisA.x, axisA.y), radius: r),
        math.pi / 2,
        math.pi,
      );
      path.lineTo(axisB.x, axisB.y - r);
      path.addArc(
        Rect.fromCircle(center: Offset(axisB.x, axisB.y), radius: r),
        -math.pi / 2,
        math.pi,
      );
      path.lineTo(axisA.x, axisA.y + r);
      path.close();
    } else {
      // Vertical capsule
      path.addArc(
        Rect.fromCircle(center: Offset(axisA.x, axisA.y), radius: r),
        math.pi,
        math.pi,
      );
      path.lineTo(axisB.x + r, axisB.y);
      path.addArc(
        Rect.fromCircle(center: Offset(axisB.x, axisB.y), radius: r),
        0,
        math.pi,
      );
      path.lineTo(axisA.x - r, axisA.y);
      path.close();
    }

    // Fill + stroke
    final fill = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Medial axis
    final axisPaint = Paint()
      ..color = Colors.deepOrange.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(axisA.x, axisA.y), Offset(axisB.x, axisB.y),
        axisPaint);
    canvas.drawCircle(Offset(axisA.x, axisA.y), 3, Paint()..color = Colors.deepOrange);
    canvas.drawCircle(Offset(axisB.x, axisB.y), 3, Paint()..color = Colors.deepOrange);

    // End caps (as circles, dimmed)
    final capPaint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final cap in capsule.endCaps) {
      canvas.drawCircle(Offset(cap.center.x, cap.center.y), cap.radius, capPaint);
    }

    // Bounding box
    final bbox = capsule.boundingBox;
    final bboxPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(
        Rect.fromLTWH(bbox.x, bbox.y, bbox.width, bbox.height), bboxPaint);

    // Center dot
    canvas.drawCircle(
        Offset(center.x, center.y), 4, Paint()..color = Colors.red);

    // Hit test
    if (tapPoint != null) {
      final inside = capsule.contains(tapPoint!);
      final dotColor = inside ? Colors.green : Colors.red;
      canvas.drawCircle(
          Offset(tapPoint!.x, tapPoint!.y), 5, Paint()..color = dotColor);
      _drawLabel(
        canvas,
        inside ? 'inside' : 'outside',
        Offset(tapPoint!.x + 8, tapPoint!.y - 6),
        dotColor,
      );
    }

    // Info
    final infoY = canvasHeight - 90;
    _drawLabel(canvas, 'area: ${capsule.area.toStringAsFixed(1)}',
        Offset(16, infoY), Colors.black87);
    _drawLabel(canvas, 'perimeter: ${capsule.perimeter.toStringAsFixed(1)}',
        Offset(16, infoY + 18), Colors.black87);
    _drawLabel(canvas, 'axis: ${capsule.axisLength.toStringAsFixed(1)}  radius: ${capsule.radius.toStringAsFixed(1)}',
        Offset(16, infoY + 36), Colors.black87);
    _drawLabel(canvas, 'Tap to hit-test',
        Offset(16, infoY + 58), Colors.grey);
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
  bool shouldRepaint(covariant _CapsulePainter old) =>
      capsuleWidth != old.capsuleWidth ||
      capsuleHeight != old.capsuleHeight ||
      tapPoint != old.tapPoint;
}
