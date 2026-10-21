import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import '../util/shape_path.dart';

/// [CustomPainter] that draws a [Polygon] from an ordered vertex list.
///
/// Backs [GeoPolygon]. Polygons with fewer than three vertices paint
/// nothing. Path construction is shared via [shapeToPath].
class PolygonPainter extends CustomPainter {
  /// The geometry polygon to paint.
  final Polygon polygon;

  /// Resolved style applied to the polygon.
  final ShapeStyle style;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Creates a polygon painter.
  const PolygonPainter({
    required this.polygon,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    if (polygon.vertices.length < 3) return;
    paintShapePath(canvas, shapeToPath(polygon, mapper), style);
  }

  @override
  bool shouldRepaint(covariant PolygonPainter old) =>
      !identical(old.polygon, polygon) ||
      old.style != style ||
      old.mapper != mapper;
}
