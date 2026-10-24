import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/triangle_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [Triangle] from three vertices.
///
/// Two constructors: [GeoTriangle] from three `Offset`s, or
/// [GeoTriangle.fromGeometry] from an existing [Triangle]. Style flows
/// from [style], the closest [ShapeStyleTheme], or a default 1px black
/// stroke. [onTap] / [onHoverChanged] hit-test against the triangle
/// outline — taps in the widget rect but outside the three edges are
/// ignored.
class GeoTriangle extends GeoShapeWidget {
  /// The geometry triangle to paint.
  final Triangle triangle;

  /// Creates a triangle widget from three vertex offsets.
  GeoTriangle({
    super.key,
    required Offset a,
    required Offset b,
    required Offset c,
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
  }) : triangle = Triangle(
         Point(a.dx, a.dy),
         Point(b.dx, b.dy),
         Point(c.dx, c.dy),
       );

  /// Creates a triangle widget from an existing [Triangle] geometry.
  const GeoTriangle.fromGeometry({
    super.key,
    required this.triangle,
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
  Geometry get geometry => triangle;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      TrianglePainter(triangle: triangle, style: resolved, mapper: mapper);
}
