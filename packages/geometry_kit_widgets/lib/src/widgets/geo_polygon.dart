import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/polygon_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [Polygon] from an ordered vertex list.
///
/// Two constructors: [GeoPolygon] from a `List<Offset>` (≥ 3 points), or
/// [GeoPolygon.fromGeometry] from an existing [Polygon]. Style flows
/// from [style], the closest [ShapeStyleTheme], or a default 1px black
/// stroke. [onTap] / [onHoverChanged] use shape-precise hit-test — taps
/// inside the widget rect but outside the polygon outline are ignored.
class GeoPolygon extends GeoShapeWidget {
  /// The geometry polygon to paint.
  final Polygon polygon;

  /// Creates a polygon widget from a list of vertex offsets.
  GeoPolygon({
    super.key,
    required List<Offset> vertices,
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
  }) : assert(vertices.length >= 3),
       polygon = Polygon(
         vertices.map((o) => Point(o.dx, o.dy)).toList(growable: false),
       );

  /// Creates a polygon widget from an existing [Polygon] geometry.
  const GeoPolygon.fromGeometry({
    super.key,
    required this.polygon,
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
  Geometry get geometry => polygon;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      PolygonPainter(polygon: polygon, style: resolved, mapper: mapper);
}
