import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import '../util/shape_path.dart';

/// [CustomPainter] that draws a [Quadrilateral] from four ordered vertices.
///
/// Backs [GeoQuadrilateral]. Path construction is shared via [shapeToPath].
class QuadrilateralPainter extends CustomPainter {
  /// The geometry quadrilateral to paint.
  final Quadrilateral quad;

  /// Resolved style applied to the quadrilateral.
  final ShapeStyle style;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Creates a quadrilateral painter.
  const QuadrilateralPainter({
    required this.quad,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    paintShapePath(canvas, shapeToPath(quad, mapper), style);
  }

  @override
  bool shouldRepaint(covariant QuadrilateralPainter old) =>
      !identical(old.quad, quad) || old.style != style || old.mapper != mapper;
}
