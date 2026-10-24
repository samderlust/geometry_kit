import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [Ray]: a half-line from an origin, cut where it
/// leaves the widget.
///
/// Two constructors: [GeoRay] from an origin and an angle in degrees
/// (counter-clockwise from +X in geometry space), or [GeoRay.fromGeometry]
/// from an existing [Ray]. Stroked only; hit-tests by distance to the
/// visible part.
class GeoRay extends GeoShapeWidget {
  /// The geometry ray to paint.
  final Ray ray;

  /// Creates a ray from [origin] at [angleDeg] degrees.
  GeoRay({
    super.key,
    required Offset origin,
    required double angleDeg,
    super.style,
    super.mapper,
    super.size,
    super.clipBehavior,
    super.semanticLabel,
    super.onTap,
    super.onHoverChanged,
    super.onDragStart,
    super.onDragUpdate,
    super.onDragEnd,
    super.debugOverlay,
  }) : ray = Ray.fromAngle(Point(origin.dx, origin.dy), angleDeg);

  /// Creates a ray widget from an existing [Ray] geometry.
  const GeoRay.fromGeometry({
    super.key,
    required this.ray,
    super.style,
    super.mapper,
    super.size,
    super.clipBehavior,
    super.semanticLabel,
    super.onTap,
    super.onHoverChanged,
    super.onDragStart,
    super.onDragUpdate,
    super.onDragEnd,
    super.debugOverlay,
  });

  @override
  Geometry get geometry => ray;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      GeometryPainter(shape: ray, style: resolved, mapper: mapper);
}
