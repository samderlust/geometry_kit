import 'package:flutter/widgets.dart';
import 'package:geometry_kit/geometry_kit.dart';

import '../coord/coordinate_mapper.dart';
import '../debug/geo_debug_overlay.dart';
import '../painters/geometry_painter.dart';
import '../style/shape_style.dart';
import '../style/shape_style_theme.dart';
import '../util/shape_hit_test.dart';
import 'geo_shape_container.dart';

/// A widget that paints a [QuadraticBezier] or a [CubicBezier].
///
/// Three constructors: [GeoBezierCurve.quadratic] (one control point),
/// [GeoBezierCurve.cubic] (two), or [GeoBezierCurve.fromGeometry] with
/// either curve type. The curve is stroked only (a `fillColor`-only style
/// strokes in that color) and hit-tests by distance to the curve. Turn on
/// `debugOverlay` vertices to see the control points and handles.
class GeoBezierCurve extends StatelessWidget {
  /// The curve to paint: a [QuadraticBezier] or a [CubicBezier].
  final Geometry curve;

  /// Style override. When `null`, resolves through [ShapeStyleTheme].
  final ShapeStyle? style;

  /// Coordinate mapper. Defaults to [CoordinateMapper.identity].
  final CoordinateMapper mapper;

  /// Logical size of the widget.
  final Size size;

  /// How content extending past [size] is clipped.
  final Clip clipBehavior;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Fires when the pointer is released on the shape.
  final VoidCallback? onTap;

  /// Fires with `true` on hover entry, `false` on exit.
  final ValueChanged<bool>? onHoverChanged;

  /// Fires when a drag that starts on the shape begins.
  ///
  /// Setting any drag callback makes the shape draggable. While the drag is
  /// in flight the widget draws the shape displaced by the pointer; no
  /// geometry is rebuilt per frame.
  final VoidCallback? onDragStart;

  /// Fires per drag frame with the pointer delta in geometry space (the
  /// [mapper]'s Y flip applied). Informational — the widget already draws
  /// the drag; do not also move the geometry here.
  final ValueChanged<Offset>? onDragUpdate;

  /// Fires when the drag ends with the total displacement in geometry
  /// space. The drawn offset then resets, so commit the move here by
  /// translating the geometry.
  final ValueChanged<Offset>? onDragEnd;

  /// Optional authoring aids (bounding box, center, vertices, dimensions)
  /// drawn above the shape.
  final GeoDebugOverlay? debugOverlay;

  /// Creates a quadratic Bezier from [start] to [end] pulled toward
  /// [control].
  GeoBezierCurve.quadratic({
    super.key,
    required Offset start,
    required Offset control,
    required Offset end,
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
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
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
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
    this.style,
    this.mapper = CoordinateMapper.identity,
    this.size = const Size(200, 200),
    this.clipBehavior = Clip.hardEdge,
    this.semanticLabel,
    this.onTap,
    this.onHoverChanged,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.debugOverlay,
  }) : assert(
         curve is QuadraticBezier || curve is CubicBezier,
         'GeoBezierCurve takes a QuadraticBezier or a CubicBezier',
       );

  @override
  Widget build(BuildContext context) {
    final resolved = ShapeStyleTheme.resolve(context, style);
    return GeoShapeContainer(
      size: size,
      clipBehavior: clipBehavior,
      semanticLabel: semanticLabel,
      geometry: curve,
      mapper: mapper,
      debugOverlay: debugOverlay,
      hitTolerance: curveHitTolerance(resolved),
      onTap: onTap,
      onHoverChanged: onHoverChanged,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      painter: GeometryPainter(shape: curve, style: resolved, mapper: mapper),
    );
  }
}
