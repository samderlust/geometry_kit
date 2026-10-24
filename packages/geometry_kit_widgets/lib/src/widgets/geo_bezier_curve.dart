import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import 'geo_shape_widget.dart';

/// A widget that paints a [QuadraticBezier] or a [CubicBezier].
///
/// Three constructors: [GeoBezierCurve.quadratic] (one control point),
/// [GeoBezierCurve.cubic] (two), or [GeoBezierCurve.fromGeometry] with
/// either curve type. The curve is stroked only (a `fillColor`-only style
/// strokes in that color) and hit-tests by distance to the curve. Turn on
/// `debugOverlay` vertices to see the control points and handles.
class GeoBezierCurve extends GeoShapeWidget {
  /// The curve to paint: a [QuadraticBezier] or a [CubicBezier].
  final Geometry curve;

  /// Creates a quadratic Bezier from [start] to [end] pulled toward
  /// [control].
  GeoBezierCurve.quadratic({
    super.key,
    required Offset start,
    required Offset control,
    required Offset end,
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
  }) : curve = QuadraticBezier(
         start: Point(start.dx, start.dy),
         control: Point(control.dx, control.dy),
         end: Point(end.dx, end.dy),
       );

  /// Creates a cubic Bezier from [start] to [end] shaped by [control1] and
  /// [control2].
  GeoBezierCurve.cubic({
    super.key,
    required Offset start,
    required Offset control1,
    required Offset control2,
    required Offset end,
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
  }) : curve = CubicBezier(
         start: Point(start.dx, start.dy),
         control1: Point(control1.dx, control1.dy),
         control2: Point(control2.dx, control2.dy),
         end: Point(end.dx, end.dy),
       );

  /// Creates a Bezier widget from an existing [QuadraticBezier] or
  /// [CubicBezier].
  const GeoBezierCurve.fromGeometry({
    super.key,
    required this.curve,
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
  }) : assert(
         curve is QuadraticBezier || curve is CubicBezier,
         'GeoBezierCurve takes a QuadraticBezier or a CubicBezier',
       );

  @override
  Geometry get geometry => curve;

  @override
  CustomPainter createPainter(ShapeStyle resolved) =>
      GeometryPainter(shape: curve, style: resolved, mapper: mapper);
}
