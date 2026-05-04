import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';

class EllipsePainter extends CustomPainter {
  final Ellipse ellipse;
  final ShapeStyle style;
  final CoordinateMapper mapper;

  const EllipsePainter({
    required this.ellipse,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    final center = mapper.toCanvas(ellipse.center.x, ellipse.center.y);
    final rect = Rect.fromCenter(
      center: center,
      width: ellipse.radiusX * 2,
      height: ellipse.radiusY * 2,
    );
    final path = Path()..addOval(rect);
    paintShapePath(canvas, path, style);
  }

  @override
  bool shouldRepaint(covariant EllipsePainter old) =>
      !identical(old.ellipse, ellipse) ||
      old.style != style ||
      old.mapper != mapper;
}
