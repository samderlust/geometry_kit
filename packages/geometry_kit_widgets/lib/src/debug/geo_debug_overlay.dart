import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../style/dash_pattern.dart';
import '../util/arc_sector.dart';
import '../util/dashed_path.dart';
import '../util/shape_hit_test.dart';

/// Authoring aids drawn on top of a shape: its bounding box, center, key
/// points and a dimension label.
///
/// Pass one as `debugOverlay` to any `Geo*` widget, to a `StyledShape`, or
/// to `GeometryCanvas` (applies to every shape):
///
/// ```dart
/// GeoPolygon(
///   vertices: const [Offset(20, 20), Offset(180, 40), Offset(90, 170)],
///   debugOverlay: GeoDebugOverlay.all,
/// )
/// ```
///
/// What each layer shows:
///
/// - [showBoundingBox] — the axis-aligned bounds of the painted outline,
///   dashed.
/// - [showCenter] — a crosshair at the shape's center (circle / ellipse /
///   arc / ring / capsule center, rectangle / quadrilateral center, triangle
///   centroid, polygon vertex mean, line midpoint, ray origin; curves use
///   the center of their bounds).
/// - [showVertices] — dots at the defining points: corners, endpoints,
///   polyline vertices, spline control points. Bezier control points are
///   hollow dots joined to their endpoints by handle lines.
/// - [showDimensions] — a label under the shape: radius, side lengths,
///   width × height, length, sweep angle and so on.
@immutable
class GeoDebugOverlay {
  /// Draw the dashed bounding box.
  final bool showBoundingBox;

  /// Draw a crosshair at the shape's center.
  final bool showCenter;

  /// Draw dots at the shape's defining points.
  final bool showVertices;

  /// Draw a dimension label.
  final bool showDimensions;

  /// Color of every overlay layer.
  final Color color;

  /// Creates an overlay. Every layer but [showDimensions] is on by default.
  const GeoDebugOverlay({
    this.showBoundingBox = true,
    this.showCenter = true,
    this.showVertices = true,
    this.showDimensions = false,
    this.color = const Color(0xFFE91E63),
  });

  /// Every layer, including dimension labels.
  static const GeoDebugOverlay all = GeoDebugOverlay(showDimensions: true);

  /// Whether any layer is on.
  bool get isVisible =>
      showBoundingBox || showCenter || showVertices || showDimensions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoDebugOverlay &&
          other.showBoundingBox == showBoundingBox &&
          other.showCenter == showCenter &&
          other.showVertices == showVertices &&
          other.showDimensions == showDimensions &&
          other.color == color);

  @override
  int get hashCode => Object.hash(
    showBoundingBox,
    showCenter,
    showVertices,
    showDimensions,
    color,
  );
}

/// Paints [overlay] for [shape] onto [canvas].
///
/// [size] is the canvas size; it only matters for a [geo.Ray], whose path
/// is cut to the canvas.
void paintDebugOverlay(
  Canvas canvas,
  Object shape,
  CoordinateMapper mapper,
  GeoDebugOverlay overlay, {
  Size? size,
}) {
  if (!overlay.isVisible) return;
  final path = cachedShapePath(shape, mapper, size: size);
  final bounds = cachedShapeBounds(shape, mapper, size: size);
  Offset toCanvas(geo.Point p) => mapper.toCanvas(p.x, p.y);

  final line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = overlay.color;

  if (overlay.showBoundingBox && shape is! geo.Ray) {
    canvas.drawPath(
      buildDashedPath(Path()..addRect(bounds), const DashPattern([4, 3])),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = overlay.color.withValues(alpha: overlay.color.a * 0.7),
    );
  }

  if (overlay.showVertices) {
    final points = _keyPoints(shape);
    final handle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = overlay.color.withValues(alpha: overlay.color.a * 0.5);
    for (final (from, to) in points.handles) {
      canvas.drawLine(toCanvas(from), toCanvas(to), handle);
    }
    final dot = Paint()..color = overlay.color;
    for (final p in points.vertices) {
      canvas.drawCircle(toCanvas(p), 3, dot);
    }
    for (final p in points.controls) {
      canvas.drawCircle(toCanvas(p), 3, line);
    }
  }

  if (overlay.showCenter) {
    final c = switch (_center(shape)) {
      final geo.Point p => toCanvas(p),
      null => bounds.center,
    };
    canvas
      ..drawLine(c - const Offset(5, 0), c + const Offset(5, 0), line)
      ..drawLine(c - const Offset(0, 5), c + const Offset(0, 5), line);
  }

  if (overlay.showDimensions) {
    final label = _dimensions(shape, path);
    if (label != null) {
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 10, color: overlay.color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final anchor = shape is geo.Ray
          ? toCanvas(shape.origin) + const Offset(0, 6)
          : Offset(bounds.center.dx, bounds.bottom + 4);
      text.paint(canvas, anchor - Offset(text.width / 2, 0));
    }
  }
}

/// [CustomPainter] over [paintDebugOverlay]; `Geo*` widgets install it as
/// the foreground painter of their shape.
class GeoDebugOverlayPainter extends CustomPainter {
  /// The geometry being annotated.
  final Object shape;

  /// Mapper from geometry coordinates to canvas coordinates.
  final CoordinateMapper mapper;

  /// Which layers to draw.
  final GeoDebugOverlay overlay;

  /// Creates an overlay painter.
  const GeoDebugOverlayPainter({
    required this.shape,
    required this.mapper,
    required this.overlay,
  });

  @override
  void paint(Canvas canvas, Size size) =>
      paintDebugOverlay(canvas, shape, mapper, overlay, size: size);

  @override
  bool shouldRepaint(covariant GeoDebugOverlayPainter old) =>
      !identical(old.shape, shape) ||
      old.mapper != mapper ||
      old.overlay != overlay;
}

typedef _KeyPoints = ({
  List<geo.Point> vertices,
  List<geo.Point> controls,
  List<(geo.Point, geo.Point)> handles,
});

_KeyPoints _keyPoints(Object shape) {
  List<geo.Point> vertices = const [];
  List<geo.Point> controls = const [];
  List<(geo.Point, geo.Point)> handles = const [];
  switch (shape) {
    case geo.Rectangle r:
      vertices = [
        geo.Point(r.x, r.y),
        geo.Point(r.x + r.width, r.y),
        geo.Point(r.x + r.width, r.y + r.height),
        geo.Point(r.x, r.y + r.height),
      ];
    case geo.Triangle t:
      vertices = [t.a, t.b, t.c];
    case geo.Quadrilateral q:
      vertices = [q.a, q.b, q.c, q.d];
    case geo.Polygon p:
      vertices = p.vertices;
    case geo.Line l:
      vertices = [l.a, l.b];
    case geo.Polyline p:
      vertices = p.points;
    case geo.Spline s:
      vertices = s.controlPoints;
    case geo.Arc a:
      vertices = [a.startPoint, a.endPoint];
    case ArcSector s:
      vertices = [s.arc.startPoint, s.arc.endPoint];
    case geo.Capsule c:
      vertices = [c.medialAxis.a, c.medialAxis.b];
    case geo.Ray r:
      vertices = [r.origin];
    case geo.QuadraticBezier b:
      vertices = [b.start, b.end];
      controls = [b.control];
      handles = [(b.start, b.control), (b.control, b.end)];
    case geo.CubicBezier b:
      vertices = [b.start, b.end];
      controls = [b.control1, b.control2];
      handles = [(b.start, b.control1), (b.end, b.control2)];
  }
  return (vertices: vertices, controls: controls, handles: handles);
}

/// Geometry-space center, or `null` to use the center of the bounds.
geo.Point? _center(Object shape) => switch (shape) {
  geo.Circle c => c.center,
  geo.Ellipse e => e.center,
  geo.Rectangle r => r.center,
  geo.Triangle t => t.centroid,
  geo.Quadrilateral q => q.center,
  geo.Polygon p when p.vertices.isNotEmpty => geo.Point(
    p.vertices.map((v) => v.x).reduce((a, b) => a + b) / p.vertices.length,
    p.vertices.map((v) => v.y).reduce((a, b) => a + b) / p.vertices.length,
  ),
  geo.Line l => l.midPoint,
  geo.Arc a => a.center,
  ArcSector s => s.arc.center,
  geo.Ring r => r.center,
  geo.Capsule c => c.center,
  geo.Ray r => r.origin,
  _ => null,
};

String? _dimensions(Object shape, Path path) {
  String deg(double rad) => '${_fmt(rad * 180 / math.pi)}°';
  return switch (shape) {
    geo.Circle c => 'r = ${_fmt(c.radius)}',
    geo.Ellipse e => 'rx = ${_fmt(e.radiusX)}, ry = ${_fmt(e.radiusY)}',
    geo.Rectangle r => '${_fmt(r.width)} × ${_fmt(r.height)}',
    geo.Triangle t => [
      t.a.distanceTo(t.b),
      t.b.distanceTo(t.c),
      t.c.distanceTo(t.a),
    ].map(_fmt).join(', '),
    geo.Quadrilateral q => 'P = ${_fmt(q.perimeter)}',
    geo.Polygon p => 'n = ${p.vertices.length}, P = ${_fmt(p.perimeter)}',
    geo.Line l => 'L = ${_fmt(l.length)}',
    geo.Polyline p => 'L = ${_fmt(p.length)}',
    geo.Arc a => 'r = ${_fmt(a.radius)}, θ = ${deg(a.sweepAngle)}',
    ArcSector s => 'r = ${_fmt(s.arc.radius)}, θ = ${deg(s.arc.sweepAngle)}',
    geo.Ring r => 'r = ${_fmt(r.innerRadius)}–${_fmt(r.outerRadius)}',
    geo.Capsule c => 'r = ${_fmt(c.radius)}, L = ${_fmt(c.totalLength)}',
    geo.Ray r => '∠ ${deg(math.atan2(r.direction.y, r.direction.x))}',
    // Mappers are isometries, so canvas length is geometry length.
    geo.QuadraticBezier() || geo.CubicBezier() || geo.Spline() =>
      'L ≈ ${_fmt(path.computeMetrics().fold(0.0, (s, m) => s + m.length))}',
    _ => null,
  };
}

String _fmt(double v) {
  final rounded = v.roundToDouble();
  if ((v - rounded).abs() < 0.05) return rounded.toInt().toString();
  return v.toStringAsFixed(1);
}
