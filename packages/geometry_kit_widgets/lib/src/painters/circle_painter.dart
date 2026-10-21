import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import '../util/shape_path.dart';

/// [CustomPainter] that draws a [Circle] using fill + stroke from [style].
///
/// Backs [GeoCircle] and is dispatched by [GeometryCanvas] when a
/// [Circle] appears in its shape list. Path construction is shared via
/// [shapeToPath]; rendering goes through [paintShapePath].
class CirclePainter extends CustomPainter {
  /// The geometry circle to paint.
  final Circle circle;

  /// Resolved style applied to the circle.
  final ShapeStyle style;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Creates a circle painter.
  const CirclePainter({
    required this.circle,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    paintShapePath(canvas, shapeToPath(circle, mapper), style);
  }

  @override
  bool shouldRepaint(covariant CirclePainter old) =>
      !identical(old.circle, circle) ||
      old.style != style ||
      old.mapper != mapper;
}
