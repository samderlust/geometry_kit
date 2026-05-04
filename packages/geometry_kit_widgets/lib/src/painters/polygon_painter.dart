import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';

class PolygonPainter extends CustomPainter {
  final Polygon polygon;
  final ShapeStyle style;
  final CoordinateMapper mapper;

  const PolygonPainter({
    required this.polygon,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    final verts = polygon.vertices;
    if (verts.length < 3) return;
    final first = mapper.toCanvas(verts.first.x, verts.first.y);
    final path = Path()..moveTo(first.dx, first.dy);
    for (var i = 1; i < verts.length; i++) {
      final p = mapper.toCanvas(verts[i].x, verts[i].y);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    paintShapePath(canvas, path, style);
  }

  @override
  bool shouldRepaint(covariant PolygonPainter old) =>
      !identical(old.polygon, polygon) ||
      old.style != style ||
      old.mapper != mapper;
}
