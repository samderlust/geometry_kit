import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/ellipse_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import 'geo_shape_widget.dart';

/// A widget that paints an axis-aligned [Ellipse].
///
/// Two constructors: [GeoEllipse] from radii + center, or
/// [GeoEllipse.fromGeometry] from an existing [Ellipse]. Style flows from
/// the explicit [style], the closest [ShapeStyleTheme] ancestor, or a
/// default 1px black stroke. Optional [onTap] / [onHoverChanged]
/// callbacks fire only when the pointer is inside the ellipse outline
/// (shape-precise hit-test, not the host widget rect).
class GeoEllipse extends GeoShapeWidget {
  /// The geometry ellipse to paint.
  final Ellipse ellipse;

  /// Creates an ellipse widget from radii and center.
  GeoEllipse({
    super.key,
    required double radiusX,
    required double radiusY,
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
  }) : ellipse = Ellipse(
         center: Point(center.dx, center.dy),
         radiusX: radiusX,
         radiusY: radiusY,
       );

  /// Creates an ellipse widget from an existing [Ellipse] geometry.
  const GeoEllipse.fromGeometry({
    super.key,
    required this.ellipse,
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
  Geometry get geometry => ellipse;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      EllipsePainter(ellipse: ellipse, style: resolved, mapper: mapper);
}
