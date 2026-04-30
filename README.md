[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)

# Geometry Kit

A comprehensive Dart package for 2D geometry — points, lines, curves, and shapes with transforms, containment checks, intersections, and more.

## Table of Contents

- [Installing](#installing)
- [Shapes & Features](#shapes--features)
  - [Point](#point)
  - [Line (Segment)](#line-segment)
  - [Ray](#ray)
  - [Circle](#circle)
  - [Ellipse](#ellipse)
  - [Rectangle](#rectangle)
  - [Triangle](#triangle)
  - [Polygon](#polygon)
  - [Quadrilateral](#quadrilateral)
  - [Arc](#arc)
  - [Ring (Annulus)](#ring-annulus)
  - [Capsule (Stadium)](#capsule-stadium)
  - [Polyline](#polyline)
  - [Bezier Curves](#bezier-curves)
  - [Spline (Catmull-Rom)](#spline-catmull-rom)
  - [Angle Utilities](#angle-utilities)
- [Flutter Example App](#flutter-example-app)
- [Contributing](#contributing)

> **Breaking changes from `geometry_kit: ^0.1.1`**
>
> Version `1.0.0` is a full rewrite. All models have been redesigned with immutable classes, value-based equality, and a unified `Shape` base class. Code written for `^0.1.1` will not compile without changes — there is no migration path, treat it as a new API. Key differences:
>
> - `Point`, `Line`, `Circle`, `Triangle`, `Polygon` are all new implementations
> - Transform methods (`translate`, `scale`, `rotate`) now return new instances (immutable)
> - `AngleUtils` is deprecated in favor of `Rad`/`Deg` extension methods
> - Many new shapes added (see below)

## Installing

```yaml
dependencies:
  geometry_kit: <latest_version>
```

```dart
import 'package:geometry_kit/geometry_kit.dart';
```

## Shapes & Features

### Point

Immutable 2D point with arithmetic operators.

```dart
final p = Point(3, 4);
p.distanceTo(Point(0, 0));  // 5.0
p.magnitude;                // 5.0
p.normalized;               // unit vector
p.angleTo(Point(6, 8));     // radians
p.dot(Point(1, 0));         // 3.0
p.midPointTo(Point(7, 8));  // Point(5, 6)

// Operators: +, -, *, /, % (cross product)
final sum = Point(1, 2) + Point(3, 4); // Point(4, 6)

// Transforms
p.translate(10, 20);
p.scale(2.0);
p.rotate(90); // degrees
```

### Line (Segment)

Finite segment defined by two endpoints. `Segment` is a type alias for `Line`.

```dart
final line = Line(Point(0, 0), Point(4, 3));

line.length;        // 5.0
line.midPoint;      // Point(2, 1.5)
line.slope;         // 0.75
line.isVertical;    // false
line.isHorizontal;  // false

// Intersection
final other = Line(Point(0, 3), Point(4, 0));
line.intersect(other);          // true
line.getIntersectPoint(other);  // Point(x, y) or null

// Angles
line.innerAngleWith(other);  // Rad
line.outerAngleWith(other);  // Rad

// Relational queries
line.isParallelTo(other);
line.isPerpendicularTo(other);
line.distanceFromAPoint(Point(2, 5));
line.hasPoint(Point(2, 1.5));

// Interpolation & extension
line.lerp(0.5);     // same as midPoint
line.extend(10);    // extend from both ends
line.projectPoint(Point(2, 5)); // perpendicular projection

// Transforms
line.translate(5, 5);
line.scale(2.0);
line.rotate(45);
```

### Ray

Half-infinite line from an origin in a direction.

```dart
final ray = Ray(Point(0, 0), Point(1, 0)); // rightward
final ray2 = Ray.fromAngle(Point(0, 0), 45); // 45 degrees

ray.pointAt(10);                // Point(10, 0)
ray.normalizedDirection;        // unit direction vector

// Intersections
ray.intersectsLine(wall);       // Point? or null
ray.intersectsCircle(circle);   // List<Point> (0, 1, or 2)
```

### Circle

```dart
final c = Circle(radius: 10, center: Point(0, 0));

c.area;           // ~314.16
c.perimeter;      // ~62.83
c.circumference;  // alias for perimeter
c.diameter;       // 20.0

// Containment
c.contains(Point(3, 4));  // true (alias for hasPoint)
c.distanceTo(Point(15, 0)); // 5.0 (signed, negative if inside)

// Intersections
c.intersectsLine(line);           // bool
c.getLineIntersections(line);     // List<Point>
c.intersectsCircle(other);       // bool
c.getCircleIntersections(other); // List<Point>

// Tangent
c.tangentAt(Point(10, 0));  // Line perpendicular to radius

// Transforms
c.translate(x: 5, y: 5);
c.scale(2.0);
c.rotate(45);
```

### Ellipse

```dart
final e = Ellipse(center: Point(0, 0), radiusX: 10, radiusY: 6);
final circle = Ellipse.circular(center: Point(0, 0), radius: 5);

e.area;           // π × 10 × 6
e.perimeter;      // Ramanujan approximation
e.semiMajor;      // 10
e.semiMinor;      // 6
e.eccentricity;   // 0..1
e.foci;           // [Point, Point]
e.focalDistance;
e.isCircle;       // false

e.pointAt(angle);               // point on boundary
e.contains(Point(3, 2));       // true
```

### Rectangle

Axis-aligned bounding box with convenience constructors.

```dart
final rect = Rectangle(x: 0, y: 0, width: 10, height: 5);
final square = Rectangle.square(x: 0, y: 0, size: 4);
final centered = Rectangle.fromCenter(center: Point(5, 5), width: 10, height: 6);
final fromPts = Rectangle.fromPoints(Point(0, 0), Point(10, 5));

rect.area;        // 50.0
rect.perimeter;   // 30.0
rect.diagonal;    // ~11.18
rect.isSquare;    // false
rect.center;      // Point(5, 2.5)

// Corners
rect.topLeft; rect.topRight; rect.bottomLeft; rect.bottomRight;
rect.vertices;  // all four
rect.edges;     // all four Lines

rect.contains(Point(3, 2));  // true
rect.overlaps(otherRect);    // bool
rect.toPolygon();             // Polygon
```

### Triangle

```dart
final t = Triangle(Point(0, 0), Point(4, 0), Point(2, 3));
final eq = Triangle.equilateral(center: Point(0, 0), radius: 5);

t.area;       t.perimeter;
t.angles;     // [Rad, Rad, Rad]
t.sides;      // [Line AB, Line BC, Line CA]
t.vertices;   // [a, b, c]
t.height;     t.baseLine;   t.heightLine;
t.hypotenuse; // longest side

// Classification
t.isRightTriangle;  t.isEquilateral;  t.isIsosceles;
t.isAcute;          t.isObtuse;       t.isScalene;

// Notable points
t.centroid;       // (a+b+c)/3
t.circumcenter;   // equidistant from vertices
t.incenter;       // angle bisector intersection
t.orthocenter;    // altitude intersection

// Circles
t.circumscribedCircle;  // through all vertices
t.inscribedCircle;      // largest circle inside

// Containment
t.contains(Point(2, 1));  // true
```

### Polygon

```dart
final poly = Polygon([Point(0,0), Point(4,0), Point(4,3), Point(0,3)]);
final hex = Polygon.regular(sides: 6, radius: 5, center: Point(0, 0));

poly.area;       poly.perimeter;
poly.vertices;   poly.edges;

poly.contains(Point(2, 1));  // ray-casting algorithm
poly.isConvex;
poly.isClockwise;
poly.centroid;

// Bounding
poly.getBound();
poly.mostLeftPoint; poly.mostRightPoint;
poly.topPoint;      poly.bottomPoint;

// Vertex queries
poly.getClosestVertex(point);
poly.getFurthestVertex(point);

// Circles
poly.getCircumCentroid();  poly.getCircumCircle(vertices);
poly.getInnerCentroid();   poly.getInnerCircle();
```

### Quadrilateral

Specialized 4-vertex shape with classification checks.

```dart
final q = Quadrilateral(Point(0,0), Point(4,0), Point(4,3), Point(0,3));

q.sides;       // [AB, BC, CD, DA]
q.diagonalAC;  q.diagonalBD;
q.center;      q.area;  q.perimeter;

// Classification
q.isParallelogram;  q.isRectangle;  q.isSquare;
q.isRhombus;        q.isTrapezoid;  q.isKite;
q.isConvex;

q.contains(Point(2, 1));
```

### Arc

```dart
final arc = Arc.fromDegrees(
  center: Point(0, 0), radius: 10, startDeg: 0, endDeg: 90,
);

arc.length;       // arc length
arc.sectorArea;   // pie slice area
arc.startPoint;   arc.endPoint;   arc.midPoint;
arc.containsAngle(0.5);  // check if angle is within sweep
arc.pointAt(0.5);        // parametric point on arc
```

### Ring (Annulus)

Donut shape defined by two concentric circles.

```dart
final ring = Ring(center: Point(0, 0), innerRadius: 5, outerRadius: 10);

ring.area;
ring.width;               // outerRadius - innerRadius
ring.averageRadius;
ring.outerCircumference;
ring.innerCircumference;
ring.contains(Point(7, 0));  // true (between boundaries)
```

### Capsule (Stadium)

Rectangle with semicircle caps.

```dart
final cap = Capsule(medialAxis: Line(Point(0,0), Point(10,0)), radius: 3);
final cap2 = Capsule.fromRect(center: Point(5, 5), width: 20, height: 8);

cap.area;        cap.perimeter;
cap.center;      cap.axisLength;
cap.totalLength; cap.totalWidth;
cap.endCaps;     // [Circle, Circle]
cap.boundingBox; // Rectangle

cap.contains(Point(5, 2));
```

### Polyline

Open path (not closed). Useful for GPS tracks, drawn paths, route lines.

```dart
final pl = Polyline([Point(0,0), Point(5,3), Point(10,1), Point(15,4)]);

pl.length;       // total path length
pl.segmentCount;
pl.segments;     // List<Line>
pl.first; pl.last;
pl.boundingBox;  // Rectangle

pl.pointAt(0.5);  // point halfway along path

// Ramer-Douglas-Peucker simplification
final simplified = pl.simplify(2.0);
```

### Bezier Curves

Quadratic (3 control points) and cubic (4 control points).

```dart
final quad = QuadraticBezier(
  start: Point(0, 0), control: Point(5, 10), end: Point(10, 0),
);
final cubic = CubicBezier(
  start: Point(0, 0), control1: Point(3, 10),
  control2: Point(7, 10), end: Point(10, 0),
);

quad.pointAt(0.5);    // point on curve
quad.length;          // approximate arc length
quad.boundingBox;     // Rectangle
quad.split(0.5);      // [QuadraticBezier, QuadraticBezier]

cubic.pointAt(0.5);
cubic.split(0.3);     // de Casteljau subdivision
```

### Spline (Catmull-Rom)

Smooth curve passing through all control points.

```dart
final spline = Spline([
  Point(0, 0), Point(3, 5), Point(7, 2), Point(10, 8),
]);

spline.pointAt(1.5);          // point on spline (t = segment index)
spline.tangentAt(1.5);        // tangent direction at t
spline.sample(100);           // List<Point> evenly sampled
spline.approximateLength();   // arc length
spline.boundingBox();         // (min: Point, max: Point)
spline.toPolyline();          // List<Line>
```

### Angle Utilities

```dart
// Type-safe extensions
double radians = 90.0.toRad;  // π/2
double degrees = pi.toDeg;    // 180.0
```

## Flutter Example App

The `flutter_example/` directory contains 17 interactive demos using `CustomPainter` — shape drawing, hit testing, raycasting, animated transforms, bezier curves, splines, and more. See `flutter_example/lib/demos/`.

## Contributing

If you find anything that needs improvement or want to request a feature, please create an issue on [GitHub](https://github.com/samderlust/geometry_kit).

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/samderlust)
