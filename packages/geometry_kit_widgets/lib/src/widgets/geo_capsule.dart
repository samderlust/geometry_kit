import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [Capsule] (stadium): every point within
/// `radius` of a segment.
///
/// Two constructors: [GeoCapsule] from the segment endpoints [a] / [b] and
/// a radius, or [GeoCapsule.fromGeometry] from an existing [Capsule]. Any
/// orientation works; a zero-length segment paints a circle.
class GeoCapsule extends GeoShapeWidget {
  /// The geometry capsule to paint.
  final Capsule capsule;

  /// Creates a capsule around the segment from `a` to `b`.
  GeoCapsule({
    super.key,
    required Offset a,
    required Offset b,
    required double radius,
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
  }) : capsule = Capsule(
         medialAxis: Line(Point(a.dx, a.dy), Point(b.dx, b.dy)),
         radius: radius,
       );

  /// Creates a capsule widget from an existing [Capsule] geometry.
  const GeoCapsule.fromGeometry({
    super.key,
    required this.capsule,
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
  Geometry get geometry => capsule;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      GeometryPainter(shape: capsule, style: resolved, mapper: mapper);
}
