import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import '../util/shape_path.dart';

/// [CustomPainter] that draws an [Ellipse] using fill + stroke from [style].
///
/// Backs [GeoEllipse]. Path construction is shared via [shapeToPath].
class EllipsePainter extends CustomPainter {
  /// The geometry ellipse to paint.
  final Ellipse ellipse;

  /// Resolved style applied to the ellipse.
  final ShapeStyle style;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Creates an ellipse painter.
  const EllipsePainter({
    required this.ellipse,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!style.isVisible) return;
    paintShapePath(canvas, shapeToPath(ellipse, mapper), style);
  }

  @override
  bool shouldRepaint(covariant EllipsePainter old) =>
      !identical(old.ellipse, ellipse) ||
      old.style != style ||
      old.mapper != mapper;
}
