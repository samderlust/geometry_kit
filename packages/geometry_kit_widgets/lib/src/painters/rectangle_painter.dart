import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import '../util/shape_path.dart';

/// [CustomPainter] that draws a [geo.Rectangle], optionally rounded.
///
/// Backs [GeoRectangle]. Sharp rectangles use [shapeToPath]; rounded
/// variants build an `RRect` over the AABB of the mapped corners. Corner
/// radius is a widget-level concept — `geo.Rectangle` itself has no
/// radius field — so the rounded branch lives here, not in
/// `shape_path.dart`.
class RectanglePainter extends CustomPainter {
  /// The geometry rectangle to paint.
  final geo.Rectangle rectangle;

  /// Resolved style applied to the rectangle.
  final ShapeStyle style;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Corner radius applied to the rendered rect. Defaults to [Radius.zero]
  /// for sharp corners.
  final Radius cornerRadius;

  /// Creates a rectangle painter.
  const RectanglePainter({
    required this.rectangle,
    required this.style,
    required this.mapper,
    this.cornerRadius = Radius.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    final Path path;
    if (cornerRadius == Radius.zero) {
      path = shapeToPath(rectangle, mapper);
    } else {
      // Rounded variant uses the AABB of the mapped corners. Lives here,
      // not in shape_path.dart, because corner radius is a widget-level
      // styling concept — `geo.Rectangle` itself has no radius field.
      final corners = <Offset>[
        mapper.toCanvas(rectangle.x, rectangle.y),
        mapper.toCanvas(rectangle.x + rectangle.width, rectangle.y),
        mapper.toCanvas(
          rectangle.x + rectangle.width,
          rectangle.y + rectangle.height,
        ),
        mapper.toCanvas(rectangle.x, rectangle.y + rectangle.height),
      ];
      double minX = corners[0].dx, maxX = corners[0].dx;
      double minY = corners[0].dy, maxY = corners[0].dy;
      for (final c in corners) {
        if (c.dx < minX) minX = c.dx;
        if (c.dx > maxX) maxX = c.dx;
        if (c.dy < minY) minY = c.dy;
        if (c.dy > maxY) maxY = c.dy;
      }
      path = Path()
        ..addRRect(
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
