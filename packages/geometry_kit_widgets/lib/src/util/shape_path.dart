import 'package:flutter/rendering.dart';
import 'package:geometry_kit/geometry_kit.dart' as geo;

import '../coord/coordinate_mapper.dart';

/// Builds a canvas-space [Path] for [shape] using [mapper].
///
/// The path matches what each painter draws internally (sharp corners only —
/// rectangle rounding lives on `GeoRectangle.cornerRadius`, not on
/// [geo.Rectangle]). Returned paths are closed where the shape is closed
/// (`Circle`, `Ellipse`, `Triangle`, `Quadrilateral`, `Polygon`,
/// `Rectangle`); a [geo.Line] returns an open two-vertex path.
///
/// Throws [UnsupportedError] for shape types this package does not paint.
Path shapeToPath(geo.Shape shape, CoordinateMapper mapper) {
  return switch (shape) {
    geo.Circle c => _circlePath(c, mapper),
    geo.Ellipse e => _ellipsePath(e, mapper),
    geo.Rectangle r => _rectanglePath(r, mapper),
    geo.Triangle t => _trianglePath(t, mapper),
    geo.Quadrilateral q => _quadrilateralPath(q, mapper),
    geo.Polygon p => _polygonPath(p, mapper),
    geo.Line l => _linePath(l, mapper),
    _ => throw UnsupportedError(
      'shapeToPath does not support ${shape.runtimeType}',
    ),
  };
}

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
