import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';

class TrianglePainter extends CustomPainter {
  final Triangle triangle;
  final ShapeStyle style;
  final CoordinateMapper mapper;

  const TrianglePainter({
    required this.triangle,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    final a = mapper.toCanvas(triangle.a.x, triangle.a.y);
    final b = mapper.toCanvas(triangle.b.x, triangle.b.y);
    final c = mapper.toCanvas(triangle.c.x, triangle.c.y);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    paintShapePath(canvas, path, style);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter old) =>
      !identical(old.triangle, triangle) ||
      old.style != style ||
      old.mapper != mapper;
}
