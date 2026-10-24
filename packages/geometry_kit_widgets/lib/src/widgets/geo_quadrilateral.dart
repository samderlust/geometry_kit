import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/quadrilateral_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [Quadrilateral] from four ordered vertices.
///
/// Two constructors: [GeoQuadrilateral] from four `Offset`s, or
/// [GeoQuadrilateral.fromGeometry] from an existing [Quadrilateral]. Style
/// flows from [style], the closest [ShapeStyleTheme], or a default 1px
/// black stroke. [onTap] / [onHoverChanged] hit-test against the
/// quadrilateral path — taps in the widget rect but outside the four
/// edges are ignored.
class GeoQuadrilateral extends GeoShapeWidget {
  /// The geometry quadrilateral to paint.
  final Quadrilateral quad;

  /// Creates a quadrilateral widget from four vertex offsets.
  GeoQuadrilateral({
    super.key,
    required Offset a,
    required Offset b,
    required Offset c,
    required Offset d,
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
  }) : quad = Quadrilateral(
         Point(a.dx, a.dy),
         Point(b.dx, b.dy),
         Point(c.dx, c.dy),
         Point(d.dx, d.dy),
       );

  /// Creates a quadrilateral widget from an existing [Quadrilateral].
  const GeoQuadrilateral.fromGeometry({
    super.key,
    required this.quad,
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
  Geometry get geometry => quad;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      QuadrilateralPainter(quad: quad, style: resolved, mapper: mapper);
}
