import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [Ring] (annulus): the band between two
/// concentric circles.
///
/// Two constructors: [GeoRing] from radii and a center, or
/// [GeoRing.fromGeometry] from an existing [Ring]. The fill covers only the
/// band — the hole stays transparent and taps in it are ignored. The
/// stroke outlines both circles.
class GeoRing extends GeoShapeWidget {
  /// The geometry ring to paint.
  final Ring ring;

  /// Creates a ring widget. [outerRadius] must exceed [innerRadius], and
  /// [innerRadius] must be non-negative.
  GeoRing({
    super.key,
    required double innerRadius,
    required double outerRadius,
    Offset center = Offset.zero,
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
  }) : ring = Ring(
         center: Point(center.dx, center.dy),
         innerRadius: innerRadius,
         outerRadius: outerRadius,
       );

  /// Creates a ring widget from an existing [Ring] geometry.
  const GeoRing.fromGeometry({
    super.key,
    required this.ring,
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
  Geometry get geometry => ring;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      GeometryPainter(shape: ring, style: resolved, mapper: mapper);
}
