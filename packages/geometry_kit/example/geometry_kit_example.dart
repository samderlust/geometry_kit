import 'dart:math' show pi;

import 'package:geometry_kit/geometry_kit.dart';

void main() {
  // ── Point ──
  final p1 = Point(3, 4);
  print('Distance to origin: ${p1.distanceTo(Point(0, 0))}'); // 5.0
  print('Magnitude: ${p1.magnitude}'); // 5.0
  print('Normalized: ${p1.normalized}');
  print('Dot product: ${p1.dot(Point(1, 0))}'); // 3.0
  print('Midpoint: ${p1.midPointTo(Point(7, 8))}'); // Point(5, 6)
  print('Operators: ${Point(1, 2) + Point(3, 4)}'); // Point(4, 6)
  print('');

  // ── Line ──
  final line1 = Line(Point(0, 2), Point(2, 0));
  final line2 = Line(Point(0, -1), Point(3, 2));
  print('Intersect: ${line1.intersect(line2)}'); // true
  print('Intersection point: ${line1.getIntersectPoint(line2)}');
  print('Line length: ${line1.length}');
  print('Midpoint: ${line1.midPoint}');
  print('Slope: ${line1.slope}');
  print('Parallel: ${line1.isParallelTo(line2)}');
  print('Perpendicular: ${line1.isPerpendicularTo(line2)}');
  print('Lerp(0.25): ${line1.lerp(0.25)}');
  print('');

  // ── Ray ──
  final ray = Ray(Point(0, 0), Point(1, 0));
  final wall = Line(Point(5, -3), Point(5, 3));
  print('Ray hit: ${ray.intersectsLine(wall)}'); // Point(5, 0)
  print('Point at t=10: ${ray.pointAt(10)}');
  print('');

  // ── Circle ──
  final circle = Circle(radius: 10, center: Point(0, 0));
  print('Circle area: ${circle.area}');
  print('Diameter: ${circle.diameter}');
  print('Contains (3,4): ${circle.contains(Point(3, 4))}'); // true
  print('Distance to (15,0): ${circle.distanceTo(Point(15, 0))}'); // 5.0

  final circle2 = Circle(radius: 8, center: Point(12, 0));
  print('Circles intersect: ${circle.intersectsCircle(circle2)}');
  print('Intersection points: ${circle.getCircleIntersections(circle2)}');
  print('');

  // ── Ellipse ──
  final ellipse = Ellipse(center: Point(0, 0), radiusX: 10, radiusY: 6);
  print('Ellipse area: ${ellipse.area}');
  print('Eccentricity: ${ellipse.eccentricity}');
  print('Foci: ${ellipse.foci}');
  print('Contains (3,2): ${ellipse.contains(Point(3, 2))}');
  print('Point at 0: ${ellipse.pointAt(0)}');
  print('');

  // ── Rectangle ──
  final rect = Rectangle(x: 0, y: 0, width: 10, height: 5);
  print('Rect area: ${rect.area}');
  print('Diagonal: ${rect.diagonal}');
  print('Is square: ${rect.isSquare}');
  print('Contains (3,2): ${rect.contains(Point(3, 2))}');

  final rect2 = Rectangle.fromCenter(center: Point(8, 3), width: 6, height: 4);
  print('Overlaps: ${rect.overlaps(rect2)}');
  print('');

  // ── Triangle ──
  final tri = Triangle(Point(0, 0), Point(4, 0), Point(2, 3));
  print('Triangle area: ${tri.area}');
  print('Is right: ${tri.isRightTriangle}');
  print('Is scalene: ${tri.isScalene}');
  print('Centroid: ${tri.centroid}');
  print('Circumcenter: ${tri.circumcenter}');
  print('Incenter: ${tri.incenter}');
  print('Contains (2,1): ${tri.contains(Point(2, 1))}');
  print('Hypotenuse length: ${tri.hypotenuse.length}');
  print(
    'Circumscribed circle: r=${tri.circumscribedCircle.radius.toStringAsFixed(2)}',
  );
  print('Inscribed circle: r=${tri.inscribedCircle.radius.toStringAsFixed(2)}');
  print('');

  // ── Polygon ──
  final hex = Polygon.regular(sides: 6, radius: 5, center: Point(0, 0));
  print('Hexagon area: ${hex.area}');
  print('Hexagon perimeter: ${hex.perimeter}');
  print('Is convex: ${hex.isConvex}');
  print('Is clockwise: ${hex.isClockwise}');
  print('Centroid: ${hex.centroid}');

  final poly = Polygon([
    Point(1, 0),
    Point(0, 2),
    Point(0, 3),
    Point(2, 5),
    Point(3, 5),
    Point(5, 3),
    Point(5, 1),
    Point(3, 0),
  ]);
  print('Contains (5,2): ${poly.contains(Point(5, 2))}'); // true
  print('Contains (9,2): ${poly.contains(Point(9, 2))}'); // false
  print('');

  // ── Quadrilateral ──
  final quad = Quadrilateral(
    Point(0, 0),
    Point(4, 0),
    Point(4, 3),
    Point(0, 3),
  );
  print('Is rectangle: ${quad.isRectangle}');
  print('Is parallelogram: ${quad.isParallelogram}');
  print('Is rhombus: ${quad.isRhombus}');
  print('Is trapezoid: ${quad.isTrapezoid}');
  print('Contains (2,1): ${quad.contains(Point(2, 1))}');
  print('');

  // ── Arc ──
  final arc = Arc.fromDegrees(
    center: Point(0, 0),
    radius: 10,
    startDeg: 0,
    endDeg: 90,
  );
  print('Arc length: ${arc.length}');
  print('Sector area: ${arc.sectorArea}');
  print('Start: ${arc.startPoint}');
  print('End: ${arc.endPoint}');
  print('');

  // ── Ring ──
  final ring = Ring(center: Point(0, 0), innerRadius: 5, outerRadius: 10);
  print('Ring area: ${ring.area}');
  print('Ring width: ${ring.width}');
  print('Contains (7,0): ${ring.contains(Point(7, 0))}'); // true
  print('Contains (3,0): ${ring.contains(Point(3, 0))}'); // false
  print('');

  // ── Capsule ──
  final capsule = Capsule.fromRect(center: Point(0, 0), width: 20, height: 8);
  print('Capsule area: ${capsule.area}');
  print('Capsule perimeter: ${capsule.perimeter}');
  print('Axis length: ${capsule.axisLength}');
  print('Contains (5,2): ${capsule.contains(Point(5, 2))}');
  print('');

  // ── Polyline ──
  final pl = Polyline([Point(0, 0), Point(5, 3), Point(10, 1), Point(15, 4)]);
  print('Polyline length: ${pl.length}');
  print('Segment count: ${pl.segmentCount}');
  print('Point at 0.5: ${pl.pointAt(0.5)}');
  final simplified = pl.simplify(2.0);
  print(
    'Simplified: ${simplified.points.length} points (from ${pl.points.length})',
  );
  print('');

  // ── Bezier ──
  final qBez = QuadraticBezier(
    start: Point(0, 0),
    control: Point(5, 10),
    end: Point(10, 0),
  );
  print('Quadratic bezier at 0.5: ${qBez.pointAt(0.5)}');
  print('Quadratic length: ${qBez.length}');
  print('Bounding box: ${qBez.boundingBox}');
  final halves = qBez.split(0.5);
  print('Split into ${halves.length} curves');

  final cBez = CubicBezier(
    start: Point(0, 0),
    control1: Point(3, 10),
    control2: Point(7, 10),
    end: Point(10, 0),
  );
  print('Cubic bezier at 0.5: ${cBez.pointAt(0.5)}');
  print('Cubic length: ${cBez.length}');
  print('');

  // ── Spline ──
  final spline = Spline([Point(0, 0), Point(3, 5), Point(7, 2), Point(10, 8)]);
  print('Spline at t=1.5: ${spline.pointAt(1.5)}');
  print('Tangent at t=1.5: ${spline.tangentAt(1.5)}');
  print('Approx length: ${spline.approximateLength()}');
  print('Sampled points: ${spline.sample(10).length}');
  print('');

  // ── Angle utilities ──
  print('90° to rad: ${90.0.toRad}'); // π/2
  print('π to deg: ${pi.toDeg}'); // 180.0
}
