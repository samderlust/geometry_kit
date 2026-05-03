import 'package:flutter/material.dart';
import 'package:geometry_kit/geometry_kit.dart' as gk;

class RaycastingDemo extends StatefulWidget {
  const RaycastingDemo({super.key});

  @override
  State<RaycastingDemo> createState() => _RaycastingDemoState();
}

class _RaycastingDemoState extends State<RaycastingDemo> {
  gk.Point _tapTarget = gk.Point(300, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raycasting')),
      body: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _tapTarget = gk.Point(d.localPosition.dx, d.localPosition.dy);
          });
        },
        onTapDown: (d) {
          setState(() {
            _tapTarget = gk.Point(
              d.localPosition.dx,
              d.localPosition.dy,
            );
          });
        },
        child: CustomPaint(
          painter: _RaycastPainter(tapTarget: _tapTarget),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _RaycastPainter extends CustomPainter {
  final gk.Point tapTarget;

  _RaycastPainter({required this.tapTarget});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = gk.Point(size.width / 2, size.height * 0.7);

    // Walls
    final walls = <gk.Line>[
      gk.Line(gk.Point(40, 80), gk.Point(size.width - 40, 80)),
      gk.Line(gk.Point(40, 80), gk.Point(40, size.height - 80)),
      gk.Line(
        gk.Point(size.width - 40, 80),
        gk.Point(size.width - 40, size.height - 80),
      ),
      gk.Line(
        gk.Point(40, size.height - 80),
        gk.Point(size.width - 40, size.height - 80),
      ),
      // Interior walls
      gk.Line(gk.Point(120, 200), gk.Point(250, 300)),
      gk.Line(gk.Point(size.width - 120, 200), gk.Point(size.width - 80, 350)),
    ];

    // Obstacle circle
    final obstacle = gk.Circle(
      radius: 40,
      center: gk.Point(size.width * 0.6, 280),
    );

    // Draw walls
    final wallPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final w in walls) {
      canvas.drawLine(
        Offset(w.a.x, w.a.y),
        Offset(w.b.x, w.b.y),
        wallPaint,
      );
    }

    // Draw obstacle circle
    final circlePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(
      Offset(obstacle.center.x, obstacle.center.y),
      obstacle.radius,
      circlePaint,
    );

    // Compute ray direction angle from origin toward tap
    final dx = tapTarget.x - origin.x;
    final dy = tapTarget.y - origin.y;
    final angleDeg = origin.angleTo(tapTarget).toDeg;

    final ray = gk.Ray.fromAngle(origin, angleDeg);

    // Find closest hit among walls
    gk.Point? closestHit;
    double minDist = double.infinity;

    for (final wall in walls) {
      final hit = ray.intersectsLine(wall);
      if (hit != null) {
        final d = origin.distanceTo(hit);
        if (d < minDist) {
          minDist = d;
          closestHit = hit;
        }
      }
    }

    // Check circle intersection
    final circleHits = ray.intersectsCircle(obstacle);
    for (final hit in circleHits) {
      final d = origin.distanceTo(hit);
      // Only consider hits in ray direction (positive t)
      final toDot = (hit.x - origin.x) * dx + (hit.y - origin.y) * dy;
      if (toDot > 0 && d < minDist) {
        minDist = d;
        closestHit = hit;
      }
    }

    // Draw laser beam
    if (closestHit != null) {
      final laserPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(origin.x, origin.y),
        Offset(closestHit.x, closestHit.y),
        laserPaint,
      );

      // Hit point
      final hitDot = Paint()..color = Colors.red;
      canvas.drawCircle(Offset(closestHit.x, closestHit.y), 6, hitDot);

      // Distance label
      _drawLabel(
        canvas,
        '${minDist.toStringAsFixed(0)} px',
        Offset(closestHit.x + 10, closestHit.y - 18),
        Colors.red,
      );
    } else {
      // Draw toward tap if no hit
      final farPoint = ray.pointAt(800);
      final dimLaser = Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(origin.x, origin.y),
        Offset(farPoint.x, farPoint.y),
        dimLaser,
      );
    }

    // Origin dot
    final originPaint = Paint()..color = Colors.indigo;
    canvas.drawCircle(Offset(origin.x, origin.y), 7, originPaint);

    // Tap target indicator
    final targetPaint = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(tapTarget.x, tapTarget.y), 10, targetPaint);

    _drawLabel(canvas, 'Drag to aim ray', Offset(size.width / 2 - 48, 44),
        Colors.grey);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _RaycastPainter old) =>
      tapTarget != old.tapTarget;
}
