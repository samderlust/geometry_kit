import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a Catmull-Rom [Spline] through its control points.
///
/// Two constructors: [GeoSpline] from a list of points (≥ 2) and an
/// `alpha`, or [GeoSpline.fromGeometry] from an existing [Spline]. The curve
/// is flattened (24 samples per segment), stroked only, and hit-tests by
/// distance to the curve. Turn on `debugOverlay` vertices to show the
/// control points.
class GeoSpline extends GeoShapeWidget {
  /// The geometry spline to paint.
  final Spline spline;

  /// Creates a spline through [points]. [alpha] selects the
  /// parameterization: 0 uniform, 0.5 centripetal (default), 1 chordal.
  GeoSpline({
    super.key,
    required List<Offset> points,
    double alpha = 0.5,
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
       spline = Spline(
         points.map((o) => Point(o.dx, o.dy)).toList(growable: false),
         alpha: alpha,
       );

  /// Creates a spline widget from an existing [Spline] geometry.
  const GeoSpline.fromGeometry({
    super.key,
    required this.spline,
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
  Geometry get geometry => spline;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      GeometryPainter(shape: spline, style: resolved, mapper: mapper);
}
