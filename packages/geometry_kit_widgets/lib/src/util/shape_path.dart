import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';
import 'arc_sector.dart';

/// Builds a canvas-space [Path] for [shape] using [mapper].
///
/// The path matches what each painter draws internally (sharp corners only —
/// rectangle rounding lives on `GeoRectangle.cornerRadius`, not on
/// [geo.Rectangle]).
///
/// Supported geometry:
///
/// - Closed: [geo.Circle], [geo.Ellipse], [geo.Rectangle], [geo.Triangle],
///   [geo.Quadrilateral], [geo.Polygon], [geo.Capsule], [geo.Ring] (two
///   contours, [PathFillType.evenOdd] so the hole stays empty) and
///   [ArcSector].
/// - Open: [geo.Line], [geo.Polyline], [geo.Arc], [geo.QuadraticBezier],
///   [geo.CubicBezier], [geo.Spline] (sampled) and [geo.Ray].
///
/// A [geo.Ray] is infinite, so it is cut to a finite segment: long enough to
/// cross a canvas of [size] when one is given, otherwise 10 000 logical
/// pixels.
///
/// Throws [UnsupportedError] for any other type.
Path shapeToPath(Object shape, CoordinateMapper mapper, {Size? size}) {
  return switch (shape) {
    geo.Circle c => _circlePath(c, mapper),
    geo.Ellipse e => _ellipsePath(e, mapper),
    geo.Rectangle r => _rectanglePath(r, mapper),
    geo.Triangle t => _trianglePath(t, mapper),
    geo.Quadrilateral q => _quadrilateralPath(q, mapper),
    geo.Polygon p => _polygonPath(p, mapper),
    geo.Capsule c => _capsulePath(c, mapper),
    geo.Ring r => _ringPath(r, mapper),
    ArcSector s => _sectorPath(s.arc, mapper),
    geo.Line l => _linePath(l, mapper),
    geo.Polyline p => _pointsPath(p.points, mapper),
    geo.Arc a => _arcPath(a, mapper),
    geo.QuadraticBezier b => _quadraticPath(b, mapper),
    geo.CubicBezier b => _cubicPath(b, mapper),
    geo.Spline s => _pointsPath(
      s.sample(s.segmentCount * splineSamplesPerSegment + 1),
      mapper,
    ),
    geo.Ray r => _rayPath(r, mapper, size),
    _ => throw UnsupportedError(
      'shapeToPath does not support ${shape.runtimeType}',
    ),
  };
}

/// Samples taken per Catmull-Rom segment when a [geo.Spline] is flattened
/// into a path.
const int splineSamplesPerSegment = 24;

Path _circlePath(geo.Circle c, CoordinateMapper m) {
  final center = m.toCanvas(c.center.x, c.center.y);
  return Path()..addOval(Rect.fromCircle(center: center, radius: c.radius));
}

Path _ellipsePath(geo.Ellipse e, CoordinateMapper m) {
  final center = m.toCanvas(e.center.x, e.center.y);
  return Path()..addOval(
    Rect.fromCenter(
      center: center,
      width: e.radiusX * 2,
      height: e.radiusY * 2,
    ),
  );
}

Path _rectanglePath(geo.Rectangle r, CoordinateMapper m) {
  final corners = <Offset>[
    m.toCanvas(r.x, r.y),
    m.toCanvas(r.x + r.width, r.y),
    m.toCanvas(r.x + r.width, r.y + r.height),
    m.toCanvas(r.x, r.y + r.height),
  ];
  final path = Path()..moveTo(corners[0].dx, corners[0].dy);
  for (var i = 1; i < corners.length; i++) {
    path.lineTo(corners[i].dx, corners[i].dy);
  }
  return path..close();
}

Path _trianglePath(geo.Triangle t, CoordinateMapper m) {
  final a = m.toCanvas(t.a.x, t.a.y);
  final b = m.toCanvas(t.b.x, t.b.y);
  final c = m.toCanvas(t.c.x, t.c.y);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy)
    ..lineTo(c.dx, c.dy)
    ..close();
}

Path _quadrilateralPath(geo.Quadrilateral q, CoordinateMapper m) {
  final pts = [
    q.a,
    q.b,
    q.c,
    q.d,
  ].map((p) => m.toCanvas(p.x, p.y)).toList(growable: false);
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 1; i < pts.length; i++) {
    path.lineTo(pts[i].dx, pts[i].dy);
  }
  return path..close();
}

Path _polygonPath(geo.Polygon p, CoordinateMapper m) {
  final verts = p.vertices;
  if (verts.length < 3) return Path();
  final first = m.toCanvas(verts.first.x, verts.first.y);
  final path = Path()..moveTo(first.dx, first.dy);
  for (var i = 1; i < verts.length; i++) {
    final pt = m.toCanvas(verts[i].x, verts[i].y);
    path.lineTo(pt.dx, pt.dy);
  }
  return path..close();
}

Path _linePath(geo.Line l, CoordinateMapper m) {
  final a = m.toCanvas(l.a.x, l.a.y);
  final b = m.toCanvas(l.b.x, l.b.y);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy);
}

Path _pointsPath(List<geo.Point> points, CoordinateMapper m) {
  final path = Path();
  if (points.isEmpty) return path;
  final first = m.toCanvas(points.first.x, points.first.y);
  path.moveTo(first.dx, first.dy);
  for (var i = 1; i < points.length; i++) {
    final pt = m.toCanvas(points[i].x, points[i].y);
    path.lineTo(pt.dx, pt.dy);
  }
  return path;
}

Path _capsulePath(geo.Capsule c, CoordinateMapper m) {
  final a = m.toCanvas(c.medialAxis.a.x, c.medialAxis.a.y);
  final b = m.toCanvas(c.medialAxis.b.x, c.medialAxis.b.y);
  final r = c.radius;
  final axis = b - a;
  final len = axis.distance;
  if (len == 0) {
    return Path()..addOval(Rect.fromCircle(center: a, radius: r));
  }
  // Built in canvas space so a Y-flipping mapper needs no special case.
  final n = Offset(-axis.dy / len, axis.dx / len) * r;
  final radius = Radius.circular(r);
  return Path()
    ..moveTo((a + n).dx, (a + n).dy)
    ..lineTo((b + n).dx, (b + n).dy)
    ..arcToPoint(b - n, radius: radius, clockwise: false)
    ..lineTo((a - n).dx, (a - n).dy)
    ..arcToPoint(a + n, radius: radius, clockwise: false)
    ..close();
}

Path _ringPath(geo.Ring r, CoordinateMapper m) {
  final center = m.toCanvas(r.center.x, r.center.y);
  final path = Path()
    ..fillType = PathFillType.evenOdd
    ..addOval(Rect.fromCircle(center: center, radius: r.outerRadius));
  if (r.innerRadius > 0) {
    path.addOval(Rect.fromCircle(center: center, radius: r.innerRadius));
  }
  return path;
}

/// Canvas-space start angle and sweep of [a]. `geometry_kit` sweeps
/// counter-clockwise in its own frame; a Y-up mapper mirrors that.
(Rect, double, double) _arcFrame(geo.Arc a, CoordinateMapper m) {
  final center = m.toCanvas(a.center.x, a.center.y);
  final rect = Rect.fromCircle(center: center, radius: a.radius);
  final flip = m.yUp ? -1.0 : 1.0;
  return (rect, a.startAngle * flip, a.sweepAngle * flip);
}

Path _arcPath(geo.Arc a, CoordinateMapper m) {
  final (rect, start, sweep) = _arcFrame(a, m);
  return Path()..addArc(rect, start, sweep);
}

Path _sectorPath(geo.Arc a, CoordinateMapper m) {
  final (rect, start, sweep) = _arcFrame(a, m);
  if (sweep.abs() >= 2 * math.pi) return Path()..addOval(rect);
  return Path()
    ..moveTo(rect.center.dx, rect.center.dy)
    ..arcTo(rect, start, sweep, false)
    ..close();
}

Path _quadraticPath(geo.QuadraticBezier b, CoordinateMapper m) {
  final s = m.toCanvas(b.start.x, b.start.y);
  final c = m.toCanvas(b.control.x, b.control.y);
  final e = m.toCanvas(b.end.x, b.end.y);
  return Path()
    ..moveTo(s.dx, s.dy)
    ..quadraticBezierTo(c.dx, c.dy, e.dx, e.dy);
}

Path _cubicPath(geo.CubicBezier b, CoordinateMapper m) {
  final s = m.toCanvas(b.start.x, b.start.y);
  final c1 = m.toCanvas(b.control1.x, b.control1.y);
  final c2 = m.toCanvas(b.control2.x, b.control2.y);
  final e = m.toCanvas(b.end.x, b.end.y);
  return Path()
    ..moveTo(s.dx, s.dy)
    ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, e.dx, e.dy);
}

Path _rayPath(geo.Ray r, CoordinateMapper m, Size? size) {
  final o = m.toCanvas(r.origin.x, r.origin.y);
  final d = r.normalizedDirection;
  final dir = m.toCanvas(r.origin.x + d.x, r.origin.y + d.y) - o;
  final path = Path()..moveTo(o.dx, o.dy);
  if (dir == Offset.zero) return path;
  var length = 10000.0;
  if (size != null) {
    // Far enough to leave the canvas from anywhere: reach the farthest
    // corner.
    length = 1.0;
    for (final corner in [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      length = math.max(length, (corner - o).distance + 1);
    }
  }
  final end = o + dir * length;
  return path..lineTo(end.dx, end.dy);
}
