import 'dart:math';

import 'point.dart';
import 'rectangle.dart';

/// A quadratic Bezier curve defined by three control points.
///
/// The curve starts at [start], is pulled toward [control],
/// and ends at [end].
class QuadraticBezier {
  /// Start point of the curve
  final Point start;

  /// Control point
  final Point control;

  /// End point of the curve
  final Point end;

  const QuadraticBezier({
    required this.start,
    required this.control,
    required this.end,
  });

  /// Get point on curve at parameter [t] (0 = start, 1 = end)
  Point pointAt(double t) {
    final mt = 1 - t;
    return Point(
      mt * mt * start.x + 2 * mt * t * control.x + t * t * end.x,
      mt * mt * start.y + 2 * mt * t * control.y + t * t * end.y,
    );
  }

  /// Approximate bounding box by sampling points
  Rectangle get boundingBox {
    double minX = start.x, maxX = start.x;
    double minY = start.y, maxY = start.y;

    for (final p in [start, control, end]) {
      minX = min(minX, p.x);
      maxX = max(maxX, p.x);
      minY = min(minY, p.y);
      maxY = max(maxY, p.y);
    }

    // Check extrema via derivative: dt = (start - control) / (start - 2*control + end)
    for (final axis in [0, 1]) {
      final s = axis == 0 ? start.x : start.y;
      final c = axis == 0 ? control.x : control.y;
      final e = axis == 0 ? end.x : end.y;
      final denom = s - 2 * c + e;
      if (denom != 0) {
        final t = (s - c) / denom;
        if (t > 0 && t < 1) {
          final p = pointAt(t);
          minX = min(minX, p.x);
          maxX = max(maxX, p.x);
          minY = min(minY, p.y);
          maxY = max(maxY, p.y);
        }
      }
    }

    return Rectangle(x: minX, y: minY, width: maxX - minX, height: maxY - minY);
  }

  /// Approximate length by summing small line segments
  double get length {
    const steps = 50;
    double total = 0;
    var prev = start;
    for (int i = 1; i <= steps; i++) {
      final p = pointAt(i / steps);
      total += prev.distanceTo(p);
      prev = p;
    }
    return total;
  }

  /// Split curve at parameter [t] into two quadratic beziers
  List<QuadraticBezier> split(double t) {
    final ab = _lerpPt(start, control, t);
    final bc = _lerpPt(control, end, t);
    final mid = _lerpPt(ab, bc, t);
    return [
      QuadraticBezier(start: start, control: ab, end: mid),
      QuadraticBezier(start: mid, control: bc, end: end),
    ];
  }

  /// Translate the curve
  QuadraticBezier translate({double x = 0, double y = 0}) {
    return QuadraticBezier(
      start: start.translate(x, y),
      control: control.translate(x, y),
      end: end.translate(x, y),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuadraticBezier &&
        other.start == start &&
        other.control == control &&
        other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ control.hashCode ^ end.hashCode;

  @override
  String toString() =>
      'QuadraticBezier(start: $start, control: $control, end: $end)';
}

/// A cubic Bezier curve defined by four control points.
///
/// The curve starts at [start], is pulled toward [control1] and [control2],
/// and ends at [end].
class CubicBezier {
  /// Start point of the curve
  final Point start;

  /// First control point
  final Point control1;

  /// Second control point
  final Point control2;

  /// End point of the curve
  final Point end;

  const CubicBezier({
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
  });

  /// Get point on curve at parameter [t] (0 = start, 1 = end)
  Point pointAt(double t) {
    final mt = 1 - t;
    final mt2 = mt * mt;
    final t2 = t * t;
    return Point(
      mt2 * mt * start.x +
          3 * mt2 * t * control1.x +
          3 * mt * t2 * control2.x +
          t2 * t * end.x,
      mt2 * mt * start.y +
          3 * mt2 * t * control1.y +
          3 * mt * t2 * control2.y +
          t2 * t * end.y,
    );
  }

  /// Approximate bounding box
  Rectangle get boundingBox {
    double minX = start.x, maxX = start.x;
    double minY = start.y, maxY = start.y;

    // Sample points + control points for conservative bound
    for (final p in [start, control1, control2, end]) {
      minX = min(minX, p.x);
      maxX = max(maxX, p.x);
      minY = min(minY, p.y);
      maxY = max(maxY, p.y);
    }

    return Rectangle(x: minX, y: minY, width: maxX - minX, height: maxY - minY);
  }

  /// Approximate length by summing small line segments
  double get length {
    const steps = 50;
    double total = 0;
    var prev = start;
    for (int i = 1; i <= steps; i++) {
      final p = pointAt(i / steps);
      total += prev.distanceTo(p);
      prev = p;
    }
    return total;
  }

  /// Split curve at parameter [t] into two cubic beziers (de Casteljau)
  List<CubicBezier> split(double t) {
    final ab = _lerpPt(start, control1, t);
    final bc = _lerpPt(control1, control2, t);
    final cd = _lerpPt(control2, end, t);
    final abc = _lerpPt(ab, bc, t);
    final bcd = _lerpPt(bc, cd, t);
    final mid = _lerpPt(abc, bcd, t);
    return [
      CubicBezier(start: start, control1: ab, control2: abc, end: mid),
      CubicBezier(start: mid, control1: bcd, control2: cd, end: end),
    ];
  }

  /// Translate the curve
  CubicBezier translate({double x = 0, double y = 0}) {
    return CubicBezier(
      start: start.translate(x, y),
      control1: control1.translate(x, y),
      control2: control2.translate(x, y),
      end: end.translate(x, y),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CubicBezier &&
        other.start == start &&
        other.control1 == control1 &&
        other.control2 == control2 &&
        other.end == end;
  }

  @override
  int get hashCode =>
      start.hashCode ^ control1.hashCode ^ control2.hashCode ^ end.hashCode;

  @override
  String toString() =>
      'CubicBezier(start: $start, control1: $control1, control2: $control2, end: $end)';
}

Point _lerpPt(Point a, Point b, double t) {
  return Point(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
}
