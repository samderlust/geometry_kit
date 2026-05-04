import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';

class QuadrilateralPainter extends CustomPainter {
  final Quadrilateral quad;
  final ShapeStyle style;
  final CoordinateMapper mapper;

  const QuadrilateralPainter({
    required this.quad,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    final pts = [quad.a, quad.b, quad.c, quad.d]
        .map((p) => mapper.toCanvas(p.x, p.y))
        .toList(growable: false);
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    paintShapePath(canvas, path, style);
  }

  @override
  bool shouldRepaint(covariant QuadrilateralPainter old) =>
      !identical(old.quad, quad) ||
      old.style != style ||
      old.mapper != mapper;
}
