import 'dart:math' as math;
import 'dart:ui';

import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import '../style/shape_style.dart';
import 'shape_path.dart';

/// Extra reach, in logical pixels, beyond half the stroke width when
/// hit-testing open curves — a 1px line is otherwise impossible to tap.
const double kCurveHitSlop = 4;

/// Whether [shape] is an open curve: it has no interior, so it is stroked
/// only and hit-tested by distance to the curve rather than by containment.
bool isOpenGeometry(geo.Geometry shape) =>
    shape is geo.Line ||
    shape is geo.Polyline ||
    shape is geo.Arc ||
    shape is geo.QuadraticBezier ||
    shape is geo.CubicBezier ||
    shape is geo.Spline ||
    shape is geo.Ray;

/// Hit-test reach for an open curve drawn with [style].
double curveHitTolerance(ShapeStyle style) =>
    math.max(style.strokeWidth ?? 1.0, 1.0) / 2 + kCurveHitSlop;

class _PathEntry {
  final CoordinateMapper mapper;
  final Size? size;
  final Path path;
  List<List<Offset>>? _samples;
  Rect? _bounds;

  _PathEntry(this.mapper, this.size, this.path);

  /// The path flattened to polylines, one per contour, every ~2px.
  List<List<Offset>> get samples => _samples ??= [
    for (final metric in path.computeMetrics())
      [
        for (var d = 0.0; d < metric.length; d += 2)
          metric.getTangentForOffset(d)!.position,
        metric.getTangentForOffset(metric.length)!.position,
      ],
  ];

  /// Tight bounds of the flattened outline. [Path.getBounds] includes
  /// Bezier and conic control points, which can sit far off the curve.
  Rect get bounds => _bounds ??= _tightBounds();

  Rect _tightBounds() {
    var minX = double.infinity, minY = double.infinity;
    var maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final contour in samples) {
      for (final p in contour) {
        minX = math.min(minX, p.dx);
        minY = math.min(minY, p.dy);
        maxX = math.max(maxX, p.dx);
        maxY = math.max(maxY, p.dy);
      }
    }
    if (minX > maxX) return path.getBounds();
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

final Expando<_PathEntry> _cache = Expando<_PathEntry>('shapePath');

_PathEntry _entry(geo.Geometry shape, CoordinateMapper mapper, Size? size) {
  final hit = _cache[shape];
  if (hit != null && hit.mapper == mapper && hit.size == size) return hit;
  final entry = _PathEntry(
    mapper,
    size,
    shapeToPath(shape, mapper, size: size),
  );
  _cache[shape] = entry;
  return entry;
}

/// [shapeToPath], memoised per geometry instance.
///
/// Geometry is immutable, so the path for a given instance only changes
/// with [mapper] or [size]. Hover hit-testing asks for the path on every
/// pointer move, and a dense polygon or spline is not cheap to rebuild, so
/// the last path is kept on the instance (via an [Expando]; nothing is
/// retained once the geometry is collected). The returned path is shared —
/// callers must not mutate it.
Path cachedShapePath(
  geo.Geometry shape,
  CoordinateMapper mapper, {
  Size? size,
}) => _entry(shape, mapper, size).path;

/// Tight canvas-space bounds of [shape]'s outline (within the ~2px sampling
/// step), memoised like [cachedShapePath].
Rect cachedShapeBounds(
  geo.Geometry shape,
  CoordinateMapper mapper, {
  Size? size,
}) => _entry(shape, mapper, size).bounds;

/// Whether canvas-space [position] hits [shape].
///
/// Closed shapes test containment of their outline. Open curves
/// ([isOpenGeometry]) test distance to the curve against [tolerance].
bool hitTestShape(
  geo.Geometry shape,
  CoordinateMapper mapper,
  Offset position, {
  double tolerance = kCurveHitSlop,
  Size? size,
}) {
  final entry = _entry(shape, mapper, size);
  if (!isOpenGeometry(shape)) return entry.path.contains(position);
  for (final contour in entry.samples) {
    if (contour.length == 1 &&
        (contour.first - position).distance <= tolerance) {
      return true;
    }
    for (var i = 1; i < contour.length; i++) {
      if (_distanceToSegment(position, contour[i - 1], contour[i]) <=
          tolerance) {
        return true;
      }
    }
  }
  return false;
}

double _distanceToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final lenSq = ab.dx * ab.dx + ab.dy * ab.dy;
  if (lenSq == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / lenSq).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}
