import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';

class CirclePainter extends CustomPainter {
  final Circle circle;
  final ShapeStyle style;
  final CoordinateMapper mapper;

  const CirclePainter({
    required this.circle,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    final center = mapper.toCanvas(circle.center.x, circle.center.y);
    final path = Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: circle.radius),
      );
    paintShapePath(canvas, path, style);
  }

  @override
  bool shouldRepaint(covariant CirclePainter old) =>
      !identical(old.circle, circle) ||
      old.style != style ||
      old.mapper != mapper;
}
