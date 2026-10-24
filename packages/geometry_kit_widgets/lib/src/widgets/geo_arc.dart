import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import '../util/arc_sector.dart';
import 'geo_shape_widget.dart';

/// A widget that paints an [Arc] — or, with [sector], the pie slice it
/// bounds.
///
/// Two constructors: [GeoArc] from a center, radius and start / end angles
/// in degrees, or [GeoArc.fromGeometry] from an existing [Arc]. The arc
/// sweeps counter-clockwise from start to end in geometry space (so
/// clockwise on screen under [CoordinateMapper.identity], whose Y axis
/// points down).
///
/// An open arc is stroked only and hit-tests by distance to the curve. A
/// sector ([sector] `true`) is closed by the two radii: it fills, and
/// hit-tests by containment.
class GeoArc extends GeoShapeWidget {
  /// The geometry arc to paint.
  final Arc arc;

  /// Paint the closed sector instead of the open arc.
  final bool sector;

  /// Creates an arc widget from a [radius], [center] and angles in degrees.
  GeoArc({
    super.key,
    required double radius,
    Offset center = Offset.zero,
    required double startDeg,
    required double endDeg,
    this.sector = false,
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
  }) : arc = Arc.fromDegrees(
         center: Point(center.dx, center.dy),
         radius: radius,
         startDeg: startDeg,
         endDeg: endDeg,
       );

  /// Creates an arc widget from an existing [Arc] geometry.
  const GeoArc.fromGeometry({
    super.key,
    required this.arc,
    this.sector = false,
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

  // One sector per arc instance, so rebuilds keep the geometry identity the
  // painter and the path cache key on.
  static final Expando<ArcSector> _sectors = Expando<ArcSector>();

  @override
  Geometry get geometry => sector ? (_sectors[arc] ??= ArcSector(arc)) : arc;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      GeometryPainter(shape: geometry, style: resolved, mapper: mapper);
}
