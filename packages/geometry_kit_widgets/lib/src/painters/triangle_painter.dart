import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import '../util/shape_path.dart';

/// [CustomPainter] that draws a [Triangle] from three vertices.
///
/// Backs [GeoTriangle]. Path construction is shared via [shapeToPath].
class TrianglePainter extends CustomPainter {
  /// The geometry triangle to paint.
  final Triangle triangle;

  /// Resolved style applied to the triangle.
  final ShapeStyle style;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Creates a triangle painter.
  const TrianglePainter({
    required this.triangle,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    paintShapePath(canvas, shapeToPath(triangle, mapper), style);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter old) =>
      !identical(old.triangle, triangle) ||
      old.style != style ||
      old.mapper != mapper;
}
