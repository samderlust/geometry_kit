import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';

import '../bridge/cross_section.dart';
import '../math/plane.dart';
import '../math/point3.dart';
import '../math/ray3.dart';
import '../mesh/triangulate.dart';
import 'revolved_solid.dart';

/// A right circular cone with its base disk on [baseCenter] and its apex
/// [height] along [axis].
///
/// ```dart
/// final cone = Cone(baseCenter: Point3(0, -1, 0), radius: 1, height: 2);
/// print(cone.volume);     // ~2.094
/// print(cone.halfAngle);  // ~26.57 (degrees)
///
/// final section = cone.slice(Plane.fromPointNormal(Point3.zero, Point3.unitY));
/// print(section is CircleSection); // true
/// ```
class Cone extends RevolvedSolid {
  /// Centre of the base disk.
  final Point3 baseCenter;

  /// Unit direction from the base towards the apex.
  @override
  final Point3 axis;

  /// Radius of the base disk.
  final double radius;

  /// Distance from the base to the apex.
  final double height;

  /// Creates a cone. [axis] is normalized; defaults to straight up.
  Cone({
    required this.baseCenter,
    required this.radius,
    required this.height,
    Point3 axis = Point3.unitY,
  })  : assert(radius >= 0 && height > 0),
        axis = axis.normalized;

  /// The tip of the cone.
  Point3 get apex => baseCenter + axis * height;

  /// Distance from the apex to the base rim.
  double get slantHeight => sqrt(radius * radius + height * height);

  /// Angle between the axis and the side, in degrees.
  double get halfAngle => atan2(radius, height) * 180 / pi;

  /// Area of the sloped side.
  double get lateralArea => pi * radius * slantHeight;

  @override
  Point3 get origin => baseCenter;

  @override
  List<Point> get meridian => [
        const Point(0, 0),
        Point(radius, 0),
        Point(0, height),
      ];

  @override
  double get volume => pi * radius * radius * height / 3;

  @override
  double get surfaceArea => pi * radius * (radius + slantHeight);

  /// Cross-section of this cone with [plane].
  ///
  /// The result's type tells which conic the plane cuts: [CircleSection]
  /// when the plane is perpendicular to the axis, [EllipseSection] when it
  /// is steeper than the side, [ParabolaSection] when parallel to the side,
  /// [HyperbolaSection] when shallower, or [EmptySection] when it misses.
  /// Open conics are closed by the chord where the plane crosses the base.
  ///
  /// The section's 2D frame has its u axis along the axis projected onto
  /// the plane, so an ellipse's major axis lies along local x.
  CrossSection slice(Plane plane, {int samples = 256}) {
    final n = plane.normal;
    final a = apex;
    final w = -axis; // apex → base
    final cosAxis = n.dot(axis).abs();
    final frame = PlaneFrame(
      plane.project(a),
      _inPlane(axis, n),
      n.cross(_inPlane(axis, n)),
    );
    final alpha = atan2(radius, height);
    // Angle between plane and axis: beta = asin(|n·axis|).
    final beta = asin(cosAxis.clamp(0.0, 1.0));
    const tol = 1e-9;

    // Perpendicular plane → circle (or nothing).
    if ((1 - cosAxis) < tol) {
      final t = plane.intersectRay(Ray3(a, w));
      if (t == null || t <= 0 || t > height + 1e-12) return EmptySection(frame);
      final c = a + w * t;
      return CircleSection(
        frame,
        Circle(center: frame.toLocal(c), radius: t * tan(alpha)),
        samples: samples,
      );
    }

    if (beta > alpha + tol) {
      // Ellipse: major-axis vertices are where the plane meets the two
      // generators lying in the plane spanned by the axis and u.
      final u = frame.u;
      final e = (u - axis * u.dot(axis)).normalized;
      final g1 = (w * cos(alpha) + e * sin(alpha)).normalized;
      final g2 = (w * cos(alpha) - e * sin(alpha)).normalized;
      final t1 = plane.intersectRay(Ray3(a, g1));
      final t2 = plane.intersectRay(Ray3(a, g2));
      if (t1 != null && t2 != null && t1 > 0 && t2 > 0) {
        final p1 = a + g1 * t1, p2 = a + g2 * t2;
        final c = p1.midPointTo(p2);
        final major = p1.distanceTo(p2) / 2;
        final hc = (c - a).dot(w);
        final rc = hc * tan(alpha);
        final off = ((c - a) - w * hc).magnitude;
        final minor = sqrt(max(0, rc * rc - off * off));
        final clipped = (p1 - a).dot(w) > height + 1e-12 ||
            (p2 - a).dot(w) > height + 1e-12;
        final ellipse =
            Ellipse(center: frame.toLocal(c), radiusX: major, radiusY: minor);
        if (!clipped) return EllipseSection(frame, ellipse, samples: samples);
        final outline = _sampledOutline(plane, frame, samples);
        if (outline.length < 3) return EmptySection(frame);
        return EllipseSection(frame, ellipse,
            clipped: true, clippedOutline: outline);
      }
      return EmptySection(frame);
    }

    final outline = _sampledOutline(plane, frame, samples);
    if (outline.length < 3) return EmptySection(frame);
    return (beta - alpha).abs() <= 1e-6
        ? ParabolaSection(frame, outline)
        : HyperbolaSection(frame, outline);
  }

  /// Samples the region of [plane] inside this finite cone: points where the
  /// plane crosses each generator line, closed by the base chord.
  List<Point> _sampledOutline(Plane plane, PlaneFrame frame, int samples) {
    final a = apex;
    final e1 = axis.anyPerpendicular, e2 = e1.cross(axis);
    final n = max(16, samples);
    final k = plane.constant - plane.normal.dot(a);
    final pts = List<Point3?>.filled(n, null);
    for (var i = 0; i < n; i++) {
      final th = 2 * pi * i / n;
      final rim = baseCenter + (e1 * cos(th) + e2 * sin(th)) * radius;
      final d = rim - a;
      final den = plane.normal.dot(d);
      if (den.abs() < 1e-15) continue;
      final t = k / den;
      if (t >= 0 && t <= 1) pts[i] = a + d * t;
    }
    final count = pts.where((p) => p != null).length;
    if (count == 0) return const [];
    final ring = <Point3>[];
    if (count == n) {
      ring.addAll(pts.cast<Point3>());
    } else {
      var s = 0;
      while (!(pts[s] != null && pts[(s - 1 + n) % n] == null)) {
        s++;
      }
      for (var j = 0; j < n; j++) {
        final p = pts[(s + j) % n];
        if (p == null) break;
        ring.add(p);
      }
    }
    final local = [for (final p in ring) frame.toLocal(p)];
    return signedArea2d(local) < 0 ? local.reversed.toList() : local;
  }

  static Point3 _inPlane(Point3 v, Point3 n) {
    final p = v - n * n.dot(v);
    return p.magnitudeSquared < 1e-18 ? n.anyPerpendicular : p.normalized;
  }

  @override
  Cone translate({double x = 0, double y = 0, double z = 0}) => Cone(
        baseCenter: baseCenter.translate(x: x, y: y, z: z),
        radius: radius,
        height: height,
        axis: axis,
      );

  @override
  Cone scale(double factor) => Cone(
        baseCenter: baseCenter * factor,
        radius: radius * factor.abs(),
        height: height * factor.abs(),
        axis: axis,
      );

  @override
  Cone rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) => Cone(
        baseCenter: baseCenter.rotate(axis, deg, pivot: pivot),
        radius: radius,
        height: height,
        axis: this.axis.rotate(axis, deg),
      );

  @override
  bool operator ==(Object other) =>
      other is Cone &&
      other.baseCenter == baseCenter &&
      other.axis == axis &&
      other.radius == radius &&
      other.height == height;

  @override
  int get hashCode => Object.hash(baseCenter, axis, radius, height);

  @override
  String toString() =>
      'Cone(baseCenter: $baseCenter, radius: $radius, height: $height, axis: $axis)';
}
