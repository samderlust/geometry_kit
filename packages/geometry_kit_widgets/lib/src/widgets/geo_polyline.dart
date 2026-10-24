import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import 'geo_shape_widget.dart';

/// A widget that paints an open [Polyline] through its points.
///
/// Two constructors: [GeoPolyline] from a list of points (≥ 2), or
/// [GeoPolyline.fromGeometry] from an existing [Polyline]. The last point
/// does not join the first — use `GeoPolygon` for a closed outline. Stroked
/// only; hit-tests by distance to the segments. Turn on `debugOverlay`
/// vertices to show the points.
class GeoPolyline extends GeoShapeWidget {
  /// The geometry polyline to paint.
  final Polyline polyline;

  /// Creates a polyline through [points].
  GeoPolyline({
    super.key,
    required List<Offset> points,
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
  }) : assert(points.length >= 2),
       polyline = Polyline(
         points.map((o) => Point(o.dx, o.dy)).toList(growable: false),
       );

  /// Creates a polyline widget from an existing [Polyline] geometry.
  const GeoPolyline.fromGeometry({
    super.key,
    required this.polyline,
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
  Geometry get geometry => polyline;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      GeometryPainter(shape: polyline, style: resolved, mapper: mapper);
}
