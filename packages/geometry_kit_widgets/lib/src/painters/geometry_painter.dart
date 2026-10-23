import 'package:flutter/rendering.dart';

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import '../util/paint_helpers.dart';
import '../util/shape_hit_test.dart';

/// Paints any geometry [shapeToPath] supports.
///
/// Closed shapes go through [paintShapePath] (fill, then stroke); open
/// curves through [paintOpenPath] (stroke only).
void paintGeometry(
  Canvas canvas,
  Object shape,
  ShapeStyle style,
  CoordinateMapper mapper, {
  Size? size,
}) {
  if (!style.isVisible) return;
  final path = cachedShapePath(shape, mapper, size: size);
  if (isOpenGeometry(shape)) {
    paintOpenPath(canvas, path, style);
  } else {
    paintShapePath(canvas, path, style);
  }
}

/// [CustomPainter] over [paintGeometry].
///
/// Backs the curve widgets (`GeoArc`, `GeoRing`, `GeoCapsule`,
/// `GeoBezierCurve`, `GeoSpline`, `GeoPolyline`, `GeoRay`). Repaints when
/// the geometry instance, style or mapper changes.
class GeometryPainter extends CustomPainter {
  /// The geometry to paint.
  final Object shape;

  /// Resolved style.
  final ShapeStyle style;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Creates a painter for [shape].
  const GeometryPainter({
    required this.shape,
    required this.style,
    required this.mapper,
  });

  @override
  void paint(Canvas canvas, Size size) =>
      paintGeometry(canvas, shape, style, mapper, size: size);

  @override
  bool shouldRepaint(covariant GeometryPainter old) =>
      !identical(old.shape, shape) ||
      old.style != style ||
      old.mapper != mapper;
}
