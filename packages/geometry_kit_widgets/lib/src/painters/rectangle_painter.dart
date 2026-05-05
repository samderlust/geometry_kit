import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';

class RectanglePainter extends CustomPainter {
  final geo.Rectangle rectangle;
  final ShapeStyle style;
  final CoordinateMapper mapper;
  final Radius cornerRadius;

  const RectanglePainter({
    required this.rectangle,
    required this.style,
    required this.mapper,
    this.cornerRadius = Radius.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;

    final corners = <Offset>[
      mapper.toCanvas(rectangle.x, rectangle.y),
      mapper.toCanvas(rectangle.x + rectangle.width, rectangle.y),
      mapper.toCanvas(
          rectangle.x + rectangle.width, rectangle.y + rectangle.height),
      mapper.toCanvas(rectangle.x, rectangle.y + rectangle.height),
    ];

    final path = Path();
    if (cornerRadius == Radius.zero) {
      path.moveTo(corners[0].dx, corners[0].dy);
      for (var i = 1; i < corners.length; i++) {
        path.lineTo(corners[i].dx, corners[i].dy);
      }
      path.close();
    } else {
      // Rounded path uses bounding rect of mapped corners.
      double minX = corners[0].dx, maxX = corners[0].dx;
      double minY = corners[0].dy, maxY = corners[0].dy;
      for (final c in corners) {
        if (c.dx < minX) minX = c.dx;
        if (c.dx > maxX) maxX = c.dx;
        if (c.dy < minY) minY = c.dy;
        if (c.dy > maxY) maxY = c.dy;
      }
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(minX, minY, maxX, maxY),
          cornerRadius,
        ),
      );
    }
    paintShapePath(canvas, path, style);
  }

  @override
  bool shouldRepaint(covariant RectanglePainter old) =>
      !identical(old.rectangle, rectangle) ||
      old.style != style ||
      old.mapper != mapper ||
      old.cornerRadius != cornerRadius;
}
